//
//  TodayViewController.swift
//  SpotifyTodayWidget
//
//  Created by Matthew Faluotico on 12/16/15.
//  Copyright © 2015 mf. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {

    var listener = Listener(withAppId: "SpotifyToday");
    var isPlaying = true;
    var firstShowing = true;
    var data = Dictionary<String, String>();
    var setup = 0;
    var appearing = 0;
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    
    override func viewWillAppear() {
        self.appearing++;
        if firstShowing {
            setUp();
        }
    }
    

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.NoData)
    }
    
    func setUp() {
        self.firstShowing = false;
        self.setListener();

        self.setup++;
        
        let apps = NSRunningApplication.runningApplicationsWithBundleIdentifier("mpf.SpotifyToday");
        let spotify = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client");
        
        guard !spotify.isEmpty
            else {
                self.listener.post("update");
                return;
        }
        
        guard !apps.isEmpty
            else {
               self.songLabel.stringValue = "Start SpotifyToday main app";
                return;
        }
        
        self.listener.post("update");
    }
    
    // MARK: Track info labsl
    
    @IBOutlet weak var songLabel: NSTextField!
    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var albumLabel: NSTextField!
    @IBOutlet weak var albumArtwork: NSImageView!
    
    // MARK: Buttons
    
    @IBOutlet weak var addButton: NSButton!
    
    @IBOutlet weak var playPauseButton: NSButton!
    
    // MARK: Button Actions
    
    @IBAction func shareButton(sender: AnyObject) {
        self.listener.post("share");
    }
    
    @IBAction func nextButton(sender: AnyObject) {
        self.listener.post("next");
    }

    @IBAction func playButton(sender: AnyObject) {
        self.listener.post("toggle");
    }
    
    @IBAction func previousButton(sender: AnyObject) {
        self.listener.post("previous");
    }
    
    @IBAction func addButton(sender: AnyObject) {
        self.listener.post("save");
    }
    
    func setListener() {
        
        self.listener.on("update_widget") {
            self.update();
        }
        
        // wait for a playback change
        Listener(withAppId: K.spPlayback).onAll { (notification) -> () in
            
            let x = notification!.userInfo!
            let playerState = x["state"] as! String!
            
            if playerState != "stopped" {
                self.listener.post("update");
            }
        }
    }
    
    func togglePlay() {
        self.playPauseButton.image = self.isPlaying ? NSImage(named: "pause") : NSImage(named: "play");
    }
    
    func update() {
        
        let defs = NSUserDefaults(suiteName: K.group);
        
        if let defaults = defs {
            self.songLabel.stringValue = defaults.stringForKey("song") ?? "Song";
            self.artistLabel.stringValue = defaults.stringForKey("artist") ?? "Artist";
            self.albumLabel.stringValue = defaults.stringForKey("album") ?? "Album";
            self.isPlaying = defaults.boolForKey("playing");
            self.togglePlay();
        }
    }
    
}
