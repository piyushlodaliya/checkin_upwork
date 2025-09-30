//
//  ContactsView.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI
import Lottie

struct ContactsView: View {
    @State private var selectedTab = 0

    let mockFollowing = [
        Contact(name: "Ali", emotion: "happy-cry", profileColor: "#FF6B6B"),
        Contact(name: "Alfonso eng 107", emotion: "angry", profileColor: "#4ECDC4"),
        Contact(name: "Alfieri Aprile", emotion: "cold-face", profileColor: "#95E1D3"),
        Contact(name: "Sarah", emotion: "gasp", profileColor: "#F3A683"),
        Contact(name: "Mike", emotion: "flushed", profileColor: "#786FA6"),
        Contact(name: "Emma", emotion: "grimacing", profileColor: "#45B7D1")
    ]

    let mockFollowers = [
        Contact(name: "Jake", emotion: "happy-cry", profileColor: "#FFA07A"),
        Contact(name: "Lisa", emotion: "cold-face", profileColor: "#98D8C8"),
        Contact(name: "Tom", emotion: "gasp", profileColor: "#F7DC6F"),
        Contact(name: "Kate", emotion: "angry", profileColor: "#BB8FCE")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    TabButton(title: "Following", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }

                    TabButton(title: "Followers", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(selectedTab == 0 ? mockFollowing : mockFollowers) { contact in
                            NavigationLink(destination: ContactDetailView(contact: contact)) {
                                ContactRow(contact: contact)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .primary : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(.systemGray6) : Color.clear)
                )
        }
    }
}

struct ContactRow: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 16) {
            LottieView(animation: .named(contact.emotion))
                .playing(loopMode: .loop)
                .frame(width: 50, height: 50)

            Text(contact.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let emotion: String
    let profileColor: String
}

#Preview {
    ContactsView()
}
