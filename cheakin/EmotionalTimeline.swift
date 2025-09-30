//
//  EmotionalTimeline.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI
import Lottie

struct EmotionalTimeline: View {
    let emotions = ["happy-cry", "angry", "cold-face", "crying", "flushed", "gasp", "grimacing"]
    let times = ["08", "11", "14", "17", "20", "23", "02", "05"]
    @State private var showInsights = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("emotional timeline")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(spacing: 6) {
                            Spacer().frame(height: 50)
                            Text(times[0])
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary.opacity(0.4))
                        }
                        .frame(width: 30)

                        ForEach(0..<7, id: \.self) { index in
                            Button(action: { showInsights = true }) {
                                VStack(spacing: 6) {
                                    LottieView(animation: .named(emotions[index]))
                                        .playing(loopMode: .loop)
                                        .frame(width: 50, height: 50)
                                    Spacer().frame(height: 14)
                                }
                            }
                            .buttonStyle(.plain)
                            .id(index)

                            VStack(spacing: 6) {
                                Spacer().frame(height: 50)
                                Text(times[index + 1])
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary.opacity(0.4))
                            }
                            .frame(width: 30)
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    proxy.scrollTo(3, anchor: .center)
                }
            }
        }
        .padding(.vertical, 0)
        .sheet(isPresented: $showInsights) {
            EmotionalInsightsView()
        }
    }
}

#Preview {
    EmotionalTimeline()
}
