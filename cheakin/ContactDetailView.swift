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
    @State private var isVisible = false
    @State private var shouldPlayAnimation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Contact header with optimized animation
                HStack(spacing: 16) {
                    if isVisible {
                        LottieView(animation: .named(contact.emotion))
                            .playing(loopMode: shouldPlayAnimation ? .playOnce : .repeat(1))
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .onTapGesture {
                                shouldPlayAnimation = true
                            }
                    } else {
                        // Static placeholder while not visible
                        Image(systemName: emotionToSFSymbol(contact.emotion))
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Active now")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
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
        .onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
    }
}

#Preview {
    NavigationView {
        ContactDetailView(contact: Contact(name: "Sarah", emotion: "happy-cry", profileColor: "#FF6B6B"))
            .environmentObject(HealthKitManager())
    }
}
