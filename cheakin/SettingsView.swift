//
//  SettingsView.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("themeMode") private var themeMode = "light"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 16)

                    VStack(spacing: 12) {
                        Text("appearance")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        HStack(spacing: 8) {
                            ThemeCapsule(
                                title: "Light",
                                icon: "sun.max.fill",
                                isSelected: themeMode == "light"
                            ) {
                                themeMode = "light"
                            }

                            ThemeCapsule(
                                title: "Dark",
                                icon: "moon.fill",
                                isSelected: themeMode == "dark"
                            ) {
                                themeMode = "dark"
                            }

                            ThemeCapsule(
                                title: "Multi",
                                icon: "paintbrush.fill",
                                isSelected: themeMode == "multi",
                                isMultiColor: true
                            ) {
                                themeMode = "multi"
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(themeMode == "dark" ? .dark : .light)
    }
}

struct ThemeCapsule: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var isMultiColor: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? (isMultiColor ? .white : .primary) : .gray)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? (isMultiColor ? .white : .primary) : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isMultiColor && isSelected {
                        LinearGradient(
                            colors: [.purple, .pink, .orange, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color(isSelected ? .systemGray6 : .systemGray5)
                            .opacity(isSelected ? 1 : 0.5)
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected && !isMultiColor ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    SettingsView()
}
