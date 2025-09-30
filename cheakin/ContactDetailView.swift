//
//  ContactDetailView.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI
import Lottie

struct ContactDetailView: View {
    let contact: Contact

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Name header
                Text(contact.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                HealthStatsBar()

                EmotionalTimeline()

                CardFeedView()
                    .frame(height: 280)
                    .padding(.top, 12)

                MusicWidget()
                    .padding(.top, 12)

                Spacer(minLength: 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ContactDetailView(contact: Contact(name: "Sarah", emotion: "happy-cry", profileColor: "#FF6B6B"))
    }
}
