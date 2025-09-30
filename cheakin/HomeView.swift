//
//  HomeView.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI
import Lottie

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HealthStatsBar()

                EmotionalTimeline()

                CardFeedView()
                    .frame(height: 380)
                    .padding(.top, 12)

                MusicWidget()
                    .padding(.top, 12)

                Spacer(minLength: 80)
            }
        }
    }
}

#Preview {
    HomeView()
}
