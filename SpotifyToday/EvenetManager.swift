//
//  EvenetManager.swift
//  SpotifyToday
//
//  Created by Matthew Faluotico on 12/16/15.
//  Copyright © 2015 mf. All rights reserved.
//

import Cocoa
import NotificationCenter

class EvenetManager {

    let listener = NSDistributedNotificationCenter();
    var centerReceiver = NSDistributedNotificationCenter();
    var data = Dictionary<String, AnyObject>();
    let request: STRequest;
    var shouldUpdate = true;
    
    init() {
        
        self.request = STRequest();
        
        listener.addObserverForName("SpotifyToday", object: nil, queue: nil) { (notification) -> Void in
            
            self.shouldUpdate = false;
            
            let cmd = notification.object as! String
        
            switch(cmd) {
            case "save" :
                self.save();
            case "share" :
                self.share();
            case "next":
                SpotifyAppleScript.progress.next();
                self.updateModel();
            case "previous":
                SpotifyAppleScript.progress.previous();
                self.updateModel();
            case "toggle" :
                SpotifyAppleScript.progress.toggle();
                self.updateModel();
            case "update" :
                self.updateModel();
            case "model" :
                self.shouldUpdate = true;
                break;
            default:
                "";
            }
            
            if !self.shouldUpdate {
                self.centerReceiver.postNotificationName("SpotifyToday", object: "model", userInfo: nil);
            }
        };
        
        listener.addObserverForName("com.spotify.client.PlaybackStateChanged", object: nil, queue: nil) { (notification) -> Void in
            
            let info = notification.userInfo!
            let state = info["Player State"]! as! String
            let controller = NCWidgetController.widgetController()
            
            if state == "Stopped" {
                controller.setHasContent(false, forWidgetWithBundleIdentifier: K.bundleWidget)
            } else{
                controller.setHasContent(true, forWidgetWithBundleIdentifier: K.bundleWidget)
            }
            
            
            self.updateModel();
        }
    }
    
    func updateModel() {
        
        self.data["state"] = SpotifyAppleScript.details.state();
        let state =  self.data["state"] as! String;
        
        if state != "kPSS" {
            self.data["song"] = SpotifyAppleScript.details.song();
            self.data["artist"] = SpotifyAppleScript.details.artist();
            self.data["album"] = SpotifyAppleScript.details.album();
            
            if state == "kPSP" {
                self.data["playing"] = true;
            } else if state == "kPSp" {
                self.data["playing"] = false;
            }
        }
        
        
        let defaults = NSUserDefaults(suiteName: "mpf.SpotifyToday.group")!;
        defaults.setPersistentDomain(self.data, forName: "mpf.SpotifyToday.group");
        defaults.synchronize();
        
    }
    
    private func strip(inout songId: String) {
        // strips the extra info from the track uri
        let range = songId.rangeOfString("spotify:track:");
        songId.replaceRange(range!, with: "");
    }
    
    func save() {
                
        var tid = SpotifyAppleScript.details.id();
        let song = SpotifyAppleScript.details.song();
        
        strip(&tid);
        print(tid);
        
        self.request.addSong(tid) { () -> () in
            print("song added");
            self.notify("share", song: song);
        }
    }
    
    func share() {
        
        var tid = SpotifyAppleScript.details.id();
        strip(&tid);
        let shareid = K.SpotifyTrackURL(tid);
        
        let pb = NSPasteboard.generalPasteboard();
        pb.clearContents();
        pb.writeObjects([shareid]);
        
        self.notify("share", song: SpotifyAppleScript.details.song());
    }
    
    func notify(type: String, song: String) {
        let notificaiton = NSUserNotification()
        
        if (type == "save") {
            notificaiton.title = "Song Added";
            notificaiton.informativeText = "\"\(song)\" has been added to your Spotify library";
        } else {
            notificaiton.title = "Share Link Copied";
            notificaiton.informativeText = "The link to \"\(song)\" has been copied to your clipboard";
        }
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notificaiton);
    }
}
