import Foundation
import HealthKit
import Combine
import Supabase

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var metrics: [HealthMetric] = []
    @Published var isAuthorized = false
    
    private var refreshTimer: Timer?
    
    func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            if self?.isAuthorized == true {
                print("🔄 Auto-refreshing health data...")
                self?.fetchAllAvailableMetrics()
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit not available on this device")
            return
        }

        let allQuantityTypes = getAllQuantityTypes()
        let allCategoryTypes = getAllCategoryTypes()
        let readTypes = Set(allQuantityTypes + allCategoryTypes)
        
        print("🔍 Requesting authorization for \(readTypes.count) health types")

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            print("✅ HealthKit authorization: \(success)")
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    print("🎉 Fetching health data...")
                    self?.fetchAllAvailableMetrics()
                    self?.startAutoRefresh()
                }
            }
        }
    }
    
    func fetchAllAvailableMetrics() {
        let allTypes = getAllQuantityTypes()
        var fetchedMetrics: [HealthMetric] = []
        
        let group = DispatchGroup()
        
        for type in allTypes {
            group.enter()
            if shouldUseCumulativeSum(for: type) {
                fetchCumulativeValue(for: type) { metric in
                    if let metric = metric {
                        fetchedMetrics.append(metric)
                        print("📊 Found: \(metric.name) = \(metric.value)")
                    }
                    group.leave()
                }
            } else {
                fetchMostRecentValue(for: type) { metric in
                    if let metric = metric {
                        fetchedMetrics.append(metric)
                        print("📊 Found: \(metric.name) = \(metric.value)")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.metrics = fetchedMetrics.sorted { $0.name < $1.name }
            print("✅ Total metrics fetched: \(self.metrics.count)")
            // Sync to Supabase after fetching
            self.syncHealthDataToSupabase()
        }
    }
    
    private func shouldUseCumulativeSum(for type: HKQuantityType) -> Bool {
        let cumulativeTypes: [String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue,
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
            HKQuantityTypeIdentifier.distanceCycling.rawValue,
            HKQuantityTypeIdentifier.distanceSwimming.rawValue,
            HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
            HKQuantityTypeIdentifier.flightsClimbed.rawValue,
            HKQuantityTypeIdentifier.appleExerciseTime.rawValue,
            HKQuantityTypeIdentifier.swimmingStrokeCount.rawValue
        ]
        return cumulativeTypes.contains(type.identifier)
    }
    
    private func fetchCumulativeValue(for type: HKQuantityType, completion: @escaping (HealthMetric?) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
            if let error = error {
                // Only log actual errors, not "no data available" which is normal
                if !error.localizedDescription.contains("No data available") {
                    print("❌ Error fetching cumulative \(type.identifier): \(error.localizedDescription)")
                }
                completion(nil)
                return
            }
            
            guard let sum = statistics?.sumQuantity() else {
                completion(nil)
                return
            }
            
            let unit = self.getUnit(for: type)
            let value = sum.doubleValue(for: unit)
            let displayValue = self.formatValue(value, unit: unit, identifier: type.identifier)
            let (icon, color) = self.getIconAndColor(for: type.identifier)
            let name = self.getReadableName(for: type.identifier)
            
            let metric = HealthMetric(
                name: name,
                value: displayValue,
                icon: icon,
                color: color,
                identifier: type.identifier
            )
            completion(metric)
        }
        healthStore.execute(query)
    }
    
    private func fetchMostRecentValue(for type: HKQuantityType, completion: @escaping (HealthMetric?) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            if let error = error {
                print("❌ Error fetching \(type.identifier): \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let sample = results?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let metric = self.createMetric(from: sample, type: type)
            completion(metric)
        }
        healthStore.execute(query)
    }
    
    private func createMetric(from sample: HKQuantitySample, type: HKQuantityType) -> HealthMetric {
        let identifier = type.identifier
        let name = getReadableName(for: identifier)
//        let unit = getUnit(for: type)
        
        let quantity = sample.quantity
        let unit = getCompatibleUnit(for: type, quantity: quantity)
        
        let value = quantity.doubleValue(for: unit)
        let displayValue = formatValue(value, unit: unit, identifier: identifier)
        let (icon, color) = getIconAndColor(for: identifier)
        
        
        return HealthMetric(
            name: name,
            value: displayValue,
            icon: icon,
            color: color,
            identifier: identifier
        )
    }
    
    func getCompatibleUnit(for type: HKQuantityType, quantity: HKQuantity) -> HKUnit {
        let identifier = type.identifier
        
        if quantity.is(compatibleWith: .count()) {
            return .count()
        }
        
        if quantity.is(compatibleWith: .meter()) {
            if Locale.current.usesMetricSystem {
                return .meter()
            } else {
                return .mile()
            }
        }
        
        if quantity.is(compatibleWith: .kilocalorie()) {
            return .kilocalorie()
        }
        
        if quantity.is(compatibleWith: .minute()) {
            return .minute()
        }

        return getUnit(for: type)
    }
    
    private func getAllQuantityTypes() -> [HKQuantityType] {
        let identifiers: [HKQuantityTypeIdentifier] = [
            .stepCount, .distanceWalkingRunning, .distanceCycling, .distanceSwimming,
            .heartRate, .restingHeartRate, .heartRateVariabilitySDNN,
            .activeEnergyBurned, .basalEnergyBurned,
            .flightsClimbed, .vo2Max,
            .appleExerciseTime, .appleStandTime,
            .respiratoryRate, .oxygenSaturation,
            .bodyMass, .bodyMassIndex, .leanBodyMass, .bodyFatPercentage,
            .runningSpeed, .runningPower, .runningStrideLength, .runningGroundContactTime, .runningVerticalOscillation,
            .swimmingStrokeCount, .cyclingSpeed, .cyclingPower, .cyclingCadence,
            .pushCount, .distanceWheelchair,
            .nikeFuel, .appleWalkingSteadiness,
            .sixMinuteWalkTestDistance, .stairAscentSpeed, .stairDescentSpeed,
            .walkingSpeed, .walkingStepLength, .walkingAsymmetryPercentage, .walkingDoubleSupportPercentage
        ]
        
        return identifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }
    }
    
    private func getAllCategoryTypes() -> [HKCategoryType] {
        let identifiers: [HKCategoryTypeIdentifier] = [
            .sleepAnalysis, .appleStandHour, .mindfulSession
        ]
        
        return identifiers.compactMap { HKCategoryType.categoryType(forIdentifier: $0) }
    }
    
    private func getUnit(for type: HKQuantityType) -> HKUnit {
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue,
             HKQuantityTypeIdentifier.flightsClimbed.rawValue,
             HKQuantityTypeIdentifier.pushCount.rawValue,
             HKQuantityTypeIdentifier.swimmingStrokeCount.rawValue:
            return .count()
            
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
             HKQuantityTypeIdentifier.distanceCycling.rawValue,
             HKQuantityTypeIdentifier.distanceSwimming.rawValue,
             HKQuantityTypeIdentifier.distanceWheelchair.rawValue,
             HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue:
            return .meterUnit(with: .kilo)
            
        case HKQuantityTypeIdentifier.heartRate.rawValue,
             HKQuantityTypeIdentifier.restingHeartRate.rawValue,
             HKQuantityTypeIdentifier.respiratoryRate.rawValue:
            return HKUnit.count().unitDivided(by: .minute())
            
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
             HKQuantityTypeIdentifier.basalEnergyBurned.rawValue:
            return .kilocalorie()
            
        case HKQuantityTypeIdentifier.runningPower.rawValue,
             HKQuantityTypeIdentifier.cyclingPower.rawValue:
            return .watt()
            
        case HKQuantityTypeIdentifier.runningSpeed.rawValue,
             HKQuantityTypeIdentifier.cyclingSpeed.rawValue,
             HKQuantityTypeIdentifier.walkingSpeed.rawValue,
             HKQuantityTypeIdentifier.stairAscentSpeed.rawValue,
             HKQuantityTypeIdentifier.stairDescentSpeed.rawValue:
            return HKUnit.meter().unitDivided(by: .second())
            
        case HKQuantityTypeIdentifier.bodyMass.rawValue,
             HKQuantityTypeIdentifier.leanBodyMass.rawValue:
            return .gramUnit(with: .kilo)
            
        case HKQuantityTypeIdentifier.oxygenSaturation.rawValue,
             HKQuantityTypeIdentifier.bodyFatPercentage.rawValue,
             HKQuantityTypeIdentifier.walkingAsymmetryPercentage.rawValue,
             HKQuantityTypeIdentifier.walkingDoubleSupportPercentage.rawValue:
            return .percent()
            
        default:
            return .count()
        }
    }
    
    private func formatValue(_ value: Double, unit: HKUnit, identifier: String) -> String {
        if unit == .meterUnit(with: .kilo) {
            return String(format: "%.1fk", value)
        } else if unit == .percent() {
            return String(format: "%.0f%%", value * 100)
        } else if unit == .watt() {
            return String(format: "%.0fW", value)
        } else if unit == HKUnit.meter().unitDivided(by: .second()) {
            return String(format: "%.1fm/s", value)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    private func getReadableName(for identifier: String) -> String {
        let mapping: [String: String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue: "Steps",
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue: "Walk/Run",
            HKQuantityTypeIdentifier.distanceCycling.rawValue: "Cycling",
            HKQuantityTypeIdentifier.distanceSwimming.rawValue: "Swimming",
            HKQuantityTypeIdentifier.heartRate.rawValue: "Heart",
            HKQuantityTypeIdentifier.restingHeartRate.rawValue: "Resting HR",
            HKQuantityTypeIdentifier.activeEnergyBurned.rawValue: "Calories",
            HKQuantityTypeIdentifier.flightsClimbed.rawValue: "Flights",
            HKQuantityTypeIdentifier.vo2Max.rawValue: "VO2 Max",
            HKQuantityTypeIdentifier.appleExerciseTime.rawValue: "Exercise",
            HKQuantityTypeIdentifier.respiratoryRate.rawValue: "Respiratory",
            HKQuantityTypeIdentifier.runningPower.rawValue: "Run Power",
            HKQuantityTypeIdentifier.runningSpeed.rawValue: "Run Speed",
            HKQuantityTypeIdentifier.swimmingStrokeCount.rawValue: "Swim Strokes",
            HKQuantityTypeIdentifier.cyclingPower.rawValue: "Cycle Power",
            HKQuantityTypeIdentifier.bodyMass.rawValue: "Weight",
            HKQuantityTypeIdentifier.oxygenSaturation.rawValue: "O2 Sat"
        ]
        
        return mapping[identifier] ?? identifier.replacingOccurrences(of: "HKQuantityTypeIdentifier", with: "")
    }
    
    private func getIconAndColor(for identifier: String) -> (String, String) {
        let mapping: [String: (String, String)] = [
            HKQuantityTypeIdentifier.stepCount.rawValue: ("figure.walk", "green"),
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue: ("figure.run", "cyan"),
            HKQuantityTypeIdentifier.distanceCycling.rawValue: ("bicycle", "blue"),
            HKQuantityTypeIdentifier.distanceSwimming.rawValue: ("figure.pool.swim", "teal"),
            HKQuantityTypeIdentifier.heartRate.rawValue: ("heart.fill", "red"),
            HKQuantityTypeIdentifier.restingHeartRate.rawValue: ("heart.circle", "pink"),
            HKQuantityTypeIdentifier.activeEnergyBurned.rawValue: ("flame.fill", "orange"),
            HKQuantityTypeIdentifier.flightsClimbed.rawValue: ("stairs", "purple"),
            HKQuantityTypeIdentifier.vo2Max.rawValue: ("lungs.fill", "blue"),
            HKQuantityTypeIdentifier.appleExerciseTime.rawValue: ("bolt.fill", "yellow"),
            HKQuantityTypeIdentifier.respiratoryRate.rawValue: ("wind", "teal"),
            HKQuantityTypeIdentifier.runningPower.rawValue: ("bolt.heart", "orange"),
            HKQuantityTypeIdentifier.runningSpeed.rawValue: ("gauge", "cyan"),
            HKQuantityTypeIdentifier.swimmingStrokeCount.rawValue: ("water.waves", "blue"),
            HKQuantityTypeIdentifier.cyclingPower.rawValue: ("bolt.circle", "yellow"),
            HKQuantityTypeIdentifier.bodyMass.rawValue: ("scalemass", "indigo"),
            HKQuantityTypeIdentifier.oxygenSaturation.rawValue: ("waveform.path.ecg", "red")
        ]
        
        return mapping[identifier] ?? ("circle.fill", "gray")
    }
    
    // MARK: - Supabase Sync
    
    func syncHealthDataToSupabase() {
        guard let currentUser = SupabaseManager.shared.currentUser else {
            print("❌ No authenticated user for health data sync")
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        print("🔄 Syncing health data to Supabase for user: \(currentUser.id)")
        
        Task {
            do {
                // Prepare health metrics for upload
                var healthData: [HealthMetricRecord] = []
                
                for metric in metrics {
                    let healthRecord = HealthMetricRecord(
                        user_id: currentUser.id.uuidString,
                        metric_type: metric.identifier,
                        value: metric.value,
                        unit: getUnitString(for: metric.identifier),
                        recorded_at: ISO8601DateFormatter().string(from: now)
                    )
                    healthData.append(healthRecord)
                }
                
                // Insert into Supabase
                let response = try await SupabaseManager.shared.client
                    .from("health_metrics")
                    .insert(healthData)
                    .execute()
                
                print("✅ Successfully synced \(healthData.count) health metrics to Supabase")
                
            } catch {
                print("❌ Error syncing health data to Supabase: \(error.localizedDescription)")
            }
        }
    }
    
    private func getUnitString(for identifier: String) -> String {
        switch identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue,
             HKQuantityTypeIdentifier.flightsClimbed.rawValue,
             HKQuantityTypeIdentifier.pushCount.rawValue,
             HKQuantityTypeIdentifier.swimmingStrokeCount.rawValue:
            return "count"
            
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
             HKQuantityTypeIdentifier.distanceCycling.rawValue,
             HKQuantityTypeIdentifier.distanceSwimming.rawValue,
             HKQuantityTypeIdentifier.distanceWheelchair.rawValue,
             HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue:
            return "km"
            
        case HKQuantityTypeIdentifier.heartRate.rawValue,
             HKQuantityTypeIdentifier.restingHeartRate.rawValue,
             HKQuantityTypeIdentifier.respiratoryRate.rawValue:
            return "bpm"
            
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
             HKQuantityTypeIdentifier.basalEnergyBurned.rawValue:
            return "kcal"
            
        case HKQuantityTypeIdentifier.runningPower.rawValue,
             HKQuantityTypeIdentifier.cyclingPower.rawValue:
            return "watts"
            
        case HKQuantityTypeIdentifier.runningSpeed.rawValue,
             HKQuantityTypeIdentifier.cyclingSpeed.rawValue,
             HKQuantityTypeIdentifier.walkingSpeed.rawValue,
             HKQuantityTypeIdentifier.stairAscentSpeed.rawValue,
             HKQuantityTypeIdentifier.stairDescentSpeed.rawValue:
            return "m/s"
            
        case HKQuantityTypeIdentifier.bodyMass.rawValue,
             HKQuantityTypeIdentifier.leanBodyMass.rawValue:
            return "kg"
            
        case HKQuantityTypeIdentifier.oxygenSaturation.rawValue,
             HKQuantityTypeIdentifier.bodyFatPercentage.rawValue,
             HKQuantityTypeIdentifier.walkingAsymmetryPercentage.rawValue,
             HKQuantityTypeIdentifier.walkingDoubleSupportPercentage.rawValue:
            return "%"
            
        default:
            return "count"
        }
    }
}

struct HealthMetric: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let icon: String
    let color: String
    let identifier: String
}

struct HealthMetricRecord: Codable {
    let user_id: String
    let metric_type: String
    let value: String
    let unit: String
    let recorded_at: String
}
