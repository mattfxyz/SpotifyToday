//
//  K.swift
//  SpotifyToday
//
//  Created by Matthew Faluotico on 12/14/15.
//  Copyright © 2015 mf. All rights reserved.
//

import Cocoa

let testies = "banana";

class K: NSObject {
    
    // MARK: URLs
    static let SpotifyAuthURL = "https://accounts.spotify.com/authorize";
    static let SpotifyTokenURL = "https://accounts.spotify.com/api/token";
    static let SpotifyRefreshURL = "https://accounts.spotify.com/api/token";
    
    // MARK: Bundles
    static let bundle = "mpf.SpotifyToday";
    static let bundleWidget = "mpf.SpotifyToday.widget";
    static let group = "mpf.apps";
    
    // MARK: Keys
    static let STCredKey = "STTokenKey";
    static let STCredSecretKey = "STTokenSecretKey";
    static let STCredRefreshToken = "STTokenRefresh";
    
    // MARK: Event keywords
    static let spPlayback = "com.spotify.client.PlaybackStateChanged";
    
    // URL generator for adding songs
    static func SpotifyAddSongURL(songID: String) -> String {
        return "https://api.spotify.com/v1/me/tracks?ids=\(songID)";
    }
    
    // URL for sharing the song
    static func SpotifyTrackURL(songID: String) -> String {
        return "https://open.spotify.com/track/\(songID)";
    }
}
