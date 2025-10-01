import SwiftUI

struct HealthStatsBar: View {
    @EnvironmentObject var healthManager: HealthKitManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if healthManager.metrics.isEmpty {
                    Text("Loading health data...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    ForEach(healthManager.metrics) { metric in
                        StatCapsule(
                            icon: metric.icon,
                            value: metric.value,
                            color: colorFromString(metric.color)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 60)
        .onAppear {
            if healthManager.isAuthorized && healthManager.metrics.isEmpty {
                healthManager.fetchAllAvailableMetrics()
            }
        }
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "green": return .green
        case "red": return .red
        case "pink": return .pink
        case "orange": return .orange
        case "cyan": return .cyan
        case "purple": return .purple
        case "blue": return .blue
        case "yellow": return .yellow
        case "indigo": return .indigo
        case "teal": return .teal
        default: return .gray
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