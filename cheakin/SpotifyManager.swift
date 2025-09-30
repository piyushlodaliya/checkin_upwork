//
//  SpotifyManager.swift
//  cheakin
//
//  Created by Arnav Gupta on 9/29/25.
//

import Foundation
import Combine  // ← Add this line

class SpotifyManager: ObservableObject {
    @Published var recentTracks: [SpotifyTrack] = []
    @Published var isAuthenticated = false

    // Spotify API credentials (you'll add these later)
    let clientID = "YOUR_CLIENT_ID"
    let redirectURI = "cheakin://callback"

    func authenticate() {
        // TODO: Implement Spotify OAuth flow
        isAuthenticated = true
    }

    func fetchRecentTracks() {
        // TODO: Make actual API call to Spotify
        recentTracks = [
            SpotifyTrack(title: "Blinding Lights", artist: "The Weeknd", albumArt: "music.note"),
            SpotifyTrack(title: "Anti-Hero", artist: "Taylor Swift", albumArt: "music.note"),
            SpotifyTrack(title: "As It Was", artist: "Harry Styles", albumArt: "music.note"),
            SpotifyTrack(title: "Die For You", artist: "The Weeknd", albumArt: "music.note")
        ]
    }
}
