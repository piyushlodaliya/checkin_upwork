import SwiftUI
import UIKit

@main
struct CheckinApp: App {
    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var contactsManager = ContactsManager()
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    @MainActor init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = nil
        appearance.backgroundColor = UIColor.clear
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if supabaseManager.isAuthenticated {
                    // Main App with Authentication
                    TabView {
                        HomeView()
                            .environmentObject(healthManager)
                            .tabItem {
                                Image(systemName: "house")
                            }

                        MapView()
                            .environmentObject(locationManager)
                            .tabItem {
                                Image(systemName: "map")
                            }

                        ContactsView()
                            .environmentObject(contactsManager)
                            .environmentObject(healthManager)
                            .tabItem {
                                Image(systemName: "person.2")
                            }

                        PublicView()
                            .tabItem {
                                Image(systemName: "globe")
                            }

                        SettingsView()
                            .environmentObject(supabaseManager)
                            .tabItem {
                                Image(systemName: "gearshape")
                            }
                    }
                    .onAppear {
                        healthManager.requestAuthorization()
                        locationManager.requestPermission()
                        contactsManager.requestAccess()
                    }
                } else {
                    // Authentication Flow
                    WelcomeView()
                        .environmentObject(supabaseManager)
                }
            }
        }
    }
}