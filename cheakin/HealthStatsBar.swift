//
//  HealthStatsBar.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI
import HealthKit
import Combine

struct HealthStatsBar: View {
    @StateObject private var healthManager = HealthKitManager()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCapsule(icon: "figure.walk", value: "\(healthManager.steps)", color: .green)
                StatCapsule(icon: "heart.fill", value: "\(healthManager.heartRate)", color: .red)
                StatCapsule(icon: "heart.circle", value: "\(healthManager.restingHeartRate)", color: .pink)
                StatCapsule(icon: "flame.fill", value: "\(healthManager.activeCalories)", color: .orange)
                StatCapsule(icon: "figure.run", value: "\(healthManager.distance)", color: .cyan)
                StatCapsule(icon: "stairs", value: "\(healthManager.flightsClimbed)", color: .purple)
                StatCapsule(icon: "lungs.fill", value: "\(healthManager.vo2Max)", color: .blue)
                StatCapsule(icon: "bolt.fill", value: "\(healthManager.workoutMinutes)", color: .yellow)
                StatCapsule(icon: "bed.double.fill", value: healthManager.sleepHours, color: .indigo)
                StatCapsule(icon: "wind", value: "\(healthManager.respiratoryRate)", color: .teal)
            }
            .padding(.horizontal)
        }
        .frame(height: 60)
        .onAppear {
            healthManager.requestAuthorization()
        }
    }
}

struct StatCapsule: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
    }
}

#Preview {
    HealthStatsBar()
}
