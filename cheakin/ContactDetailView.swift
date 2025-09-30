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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Contact Header
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(hex: contact.profileColor).opacity(0.3))
                                .frame(width: 60, height: 60)
                            
                            LottieView(animation: .named(contact.emotion))
                                .playing(loopMode: .loop)
                                .frame(width: 40, height: 40)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contact.name)
                                .font(.system(size: 22, weight: .bold))
                            Text("feeling \(contact.emotion.replacingOccurrences(of: "-", with: " "))")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    Divider()
                    
                    // Their Health Stats
                    HealthStatsBar()
                    
                    // Their Emotional Timeline
                    EmotionalTimeline()
                    
                    // Their Cards
                    CardFeedView()
                        .frame(height: 280)
                        .padding(.top, 12)
                    
                    // Their Music
                    MusicWidget()
                        .padding(.top, 12)
                    
                    Spacer(minLength: 80)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }
}

#Preview {
    ContactDetailView(contact: Contact(name: "Sarah", emotion: "happy-cry", profileColor: "#FF6B6B"))
}