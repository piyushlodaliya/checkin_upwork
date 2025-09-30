//
//  HealthKitManager.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()

    @Published var heartRate: Int = 0
    @Published var restingHeartRate: Int = 0
    @Published var steps: Int = 0
    @Published var activeCalories: Int = 0
    @Published var distance: String = "0"
    @Published var flightsClimbed: Int = 0
    @Published var vo2Max: Int = 0
    @Published var workoutMinutes: Int = 0
    @Published var sleepHours: String = "0h"
    @Published var respiratoryRate: Int = 0
    @Published var isAuthorized = false

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device")
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    self?.fetchHealthData()
                    self?.startObservingHealthData()
                } else {
                    print("HealthKit authorization failed: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }

    func fetchHealthData() {
        fetchHeartRate()
        fetchRestingHeartRate()
        fetchSteps()
        fetchActiveCalories()
        fetchDistance()
        fetchFlightsClimbed()
        fetchVO2Max()
        fetchWorkoutMinutes()
        fetchSleep()
        fetchRespiratoryRate()
    }

    // Set up live observers for real-time updates
    func startObservingHealthData() {
        observeSteps()
        observeHeartRate()
    }

    private func observeSteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let query = HKObserverQuery(sampleType: stepsType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                self?.fetchSteps()
            }
        }
        healthStore.execute(query)
    }

    private func observeHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                self?.fetchHeartRate()
            }
        }
        healthStore.execute(query)
    }

    private func fetchHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let bpm = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
            DispatchQueue.main.async {
                self?.heartRate = bpm
            }
        }
        healthStore.execute(query)
    }

    private func fetchRestingHeartRate() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let bpm = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
            DispatchQueue.main.async {
                self?.restingHeartRate = bpm
            }
        }
        healthStore.execute(query)
    }

    private func fetchSteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let sum = result?.sumQuantity() else { return }
            let steps = Int(sum.doubleValue(for: .count()))
            DispatchQueue.main.async {
                self?.steps = steps
            }
        }
        healthStore.execute(query)
    }

    private func fetchActiveCalories() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let sum = result?.sumQuantity() else { return }
            let cal = Int(sum.doubleValue(for: .kilocalorie()))
            DispatchQueue.main.async {
                self?.activeCalories = cal
            }
        }
        healthStore.execute(query)
    }

    private func fetchDistance() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let sum = result?.sumQuantity() else { return }
            let km = sum.doubleValue(for: .meterUnit(with: .kilo))
            DispatchQueue.main.async {
                self?.distance = String(format: "%.1fk", km)
            }
        }
        healthStore.execute(query)
    }

    private func fetchFlightsClimbed() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let sum = result?.sumQuantity() else { return }
            let flights = Int(sum.doubleValue(for: .count()))
            DispatchQueue.main.async {
                self?.flightsClimbed = flights
            }
        }
        healthStore.execute(query)
    }

    private func fetchVO2Max() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .vo2Max) else { return }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let vo2 = Int(sample.quantity.doubleValue(for: HKUnit.literUnit(with: .milli).unitDivided(by: .gramUnit(with: .kilo).unitMultiplied(by: .minute()))))
            DispatchQueue.main.async {
                self?.vo2Max = vo2
            }
        }
        healthStore.execute(query)
    }

    private func fetchWorkoutMinutes() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let sum = result?.sumQuantity() else { return }
            let minutes = Int(sum.doubleValue(for: .minute()))
            DispatchQueue.main.async {
                self?.workoutMinutes = minutes
            }
        }
        healthStore.execute(query)
    }

    private func fetchSleep() {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, results, error in
            guard let samples = results as? [HKCategorySample] else { return }

            let totalSeconds = samples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            let hours = totalSeconds / 3600

            DispatchQueue.main.async {
                self?.sleepHours = String(format: "%.1fh", hours)
            }
        }
        healthStore.execute(query)
    }

    private func fetchRespiratoryRate() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else { return }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let rate = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
            DispatchQueue.main.async {
                self?.respiratoryRate = rate
            }
        }
        healthStore.execute(query)
    }
}
