//
//  Checkin.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import SwiftUI

@main
struct CheckinApp: App {
  init() {
         let appearance = UITabBarAppearance()

         // 1. Configure the tab bar to be fully transparent
         appearance.configureWithTransparentBackground()

         // 2. Remove any blur or background effects
         appearance.backgroundEffect = nil

         // 3. Set a transparent background color
         appearance.backgroundColor = UIColor.clear

         // Apply this appearance to the tab bar
         UITabBar.appearance().standardAppearance = appearance
         UITabBar.appearance().scrollEdgeAppearance = appearance
     }

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                    }

                MapView()
                    .tabItem {
                        Image(systemName: "map")
                    }

                ContactsView()
                    .tabItem {
                        Image(systemName: "person.2")
                    }

                PublicView()
                    .tabItem {
                        Image(systemName: "globe")
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                    }
            }
        }
    }
}
