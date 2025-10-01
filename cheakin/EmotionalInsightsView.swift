//
//  EmotionalInsightsView.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI
import Lottie

struct EmotionalInsightsView: View {
    @Environment(\.dismiss) var dismiss

    let mockInsights = [
        EmotionLog(time: "08:00", emotion: "happy-cry", aiInsight: "Started the day with high energy and optimism"),
        EmotionLog(time: "11:00", emotion: "angry", aiInsight: "Stress peaked during work tasks, consider a break"),
        EmotionLog(time: "14:00", emotion: "cold-face", aiInsight: "Feeling overwhelmed, good time for a walk"),
        EmotionLog(time: "17:00", emotion: "gasp", aiInsight: "Emotional dip detected, reach out to friends"),
        EmotionLog(time: "20:00", emotion: "flushed", aiInsight: "Evening anxiety, try some breathing exercises"),
        EmotionLog(time: "23:00", emotion: "grimacing", aiInsight: "Late night surprise or shock moment"),
        EmotionLog(time: "02:00", emotion: "crying", aiInsight: "Sleep disruption noted, consider wind-down routine")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(mockInsights) { log in
                        HStack(alignment: .center, spacing: 16) {
                            VStack(spacing: 6) {
                                Text(log.time)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary.opacity(0.6))

                                // Static SF Symbol instead of Lottie animation for performance
                                Image(systemName: emotionToSFSymbol(log.emotion))
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .frame(width: 70)

                            Text(log.aiInsight)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("today's emotional journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EmotionLog: Identifiable {
    let id = UUID()
    let time: String
    let emotion: String
    let aiInsight: String
}

#Preview {
    EmotionalInsightsView()
}
