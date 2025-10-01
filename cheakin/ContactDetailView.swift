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
    @EnvironmentObject var healthManager: HealthKitManager

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(contact.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)

                EmotionalTimeline()

                CardFeedView()
                    .frame(height: 280)

                MusicWidget()

                Spacer(minLength: 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ContactDetailView(contact: Contact(name: "Sarah", emotion: "happy-cry", profileColor: "#FF6B6B"))
            .environmentObject(HealthKitManager())
    }
}
