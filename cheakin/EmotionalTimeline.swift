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
    @State private var animationTimers: [Timer?] = Array(repeating: nil, count: 7)
    @State private var isVisible = false

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
                                    OptimizedLottieView(
                                        animationName: emotions[index],
                                        isVisible: isVisible,
                                        onTimerSetup: { timer in
                                            animationTimers[index] = timer
                                        }
                                    )
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
                    isVisible = true
                }
                .onDisappear {
                    isVisible = false
                    // Clean up timers when view disappears
                    animationTimers.forEach { timer in
                        timer?.invalidate()
                    }
                    animationTimers = Array(repeating: nil, count: 7)
                }
            }
        }
        .padding(.vertical, 0)
        .sheet(isPresented: $showInsights) {
            EmotionalInsightsView()
        }
    }
}

struct OptimizedLottieView: View {
    let animationName: String
    let isVisible: Bool
    let onTimerSetup: (Timer?) -> Void
    
    @State private var shouldPlay = false
    @State private var isLoaded = false
    
    var body: some View {
        Group {
            if isLoaded && isVisible {
                LottieView(animation: .named(animationName))
                    .playing(loopMode: shouldPlay ? .playOnce : .repeat(1))
                    .onAppear {
                        if shouldPlay {
                            // Schedule next animation after current one finishes
                            scheduleNextAnimation()
                        }
                    }
            } else {
                // Static placeholder while not loaded
                Image(systemName: "face.smiling")
                    .font(.system(size: 30))
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
        .onAppear {
            if isVisible && !isLoaded {
                isLoaded = true
                // Start first animation after a random delay
                let initialDelay = Double.random(in: 1...3)
                DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
                    shouldPlay = true
                }
            }
        }
    }
    
    private func scheduleNextAnimation() {
        let delay = Double.random(in: 10...15)
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            shouldPlay = true
        }
        onTimerSetup(timer)
    }
}

#Preview {
    EmotionalTimeline()
}
