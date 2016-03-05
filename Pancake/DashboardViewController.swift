//
//  DashboardViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 05/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class DashboardViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {

    // Alarm outlets
    @IBOutlet weak var imageTimeDisplay: UIImageView!
    @IBOutlet weak var userDailyMessage: UILabel!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var dateDisplay: UILabel!
    @IBOutlet weak var meridiemDisplay: UILabel!
    
    // Play music
    var sound = NSURL()
    var audioPlayer = AVAudioPlayer()
    let audioSession = AVAudioSession()
    var firstMusic = true
    
    // Spotify
    var player = SPTAudioStreamingController?()
    let kClientID = "eb68da6b0f3c4589a25e1c95bd3699f3"

    let settingsInfoAlert = JSSAlertView()
    weak var firstViewController = LoginViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Spotify is checking if the user is login
        self.spotifyUserCheck()
        
        // Update Time Periodically = _ Stands for timer :P
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timeUpdate", userInfo: nil, repeats: true)
        
        // Permission for notification
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Schedules notification
        self.scheduleNotification()

        // Lets us play background music when screen is locked
        let sleepPrevent = MMPDeepSleepPreventer()
        sleepPrevent.startPreventSleep()
        
        // Checks if app is sent to background for the first time
//        if firstMusic == true {
//            let timer = NSTimer(fireDate: NSDate(timeIntervalSinceNow: 15), interval: 60, target: self, selector: "playAlarm", userInfo: nil, repeats: false)
//            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
//        }
//        firstMusic = false
//        print("We are here.")
        
        

    }

    
    // Updates Time and all its elements
    func timeUpdate(){
        
        // Creates a custom Time format
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm"
       
        // Displays time in custom format "hh:mm"
        let now = NSDate()
        let formattedTime = timeFormatter.stringFromDate(now)
        
        // ONLY Used to check if it is AM or PM
        let time = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        // Displays Date.
        self.dateDisplay.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        
        // Checks if Time is AM or PM
        if ((time.rangeOfString("AM")) != nil) {
            // It's the morning. Give some love :)
            self.userDailyMessage.text = "Good Morning"
            self.meridiemDisplay.text = "am"
        } else if ((time.rangeOfString("PM")) != nil){
            // It's already evening
            self.userDailyMessage.text = "Good Evening"
            self.meridiemDisplay.text = "pm"
        } else {
            print("Error. No time section found.")
        }
        
        // Display formatted time
        self.timeDisplay.text = formattedTime
        
        // For debugging purposes onlye
        //print(timeDisplay.text)
        
        
    }
    
    // Manages notifications
    func scheduleNotification() {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings?.types == .None {
//            let settingsInfoAlert = JSSAlertView()
//            settingsInfoAlert.show(self,
//                title: "Oops...",
//                text: "We don't have permission to wake you up",
//                buttonText: "OK",
//                color: UIColor.whiteColor())
//            return
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        // Sends Alarm notification - You need to wake up now
        let alarmNotification = UILocalNotification()
        alarmNotification.fireDate = NSDate(timeIntervalSinceNow: 20)
        alarmNotification.alertBody = "Wake up"
        alarmNotification.alertAction = "OK"
        alarmNotification.userInfo = ["CustomField": "Woot"]
        UIApplication.sharedApplication().scheduleLocalNotification(alarmNotification)
        
        
    }
    
    // MARK: - Alarm
    func playAlarm() {
        
//        do {
//            // Keeps audio playing in the background
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            print("AVAudioSession Category Playback OK")
//            do {
//                try AVAudioSession.sharedInstance().setActive(true)
//                print("AVAudioSession is Active")
//            } catch let error as NSError {
//                // Needs better error handling
//                print(error.localizedDescription)
//            }
//        } catch let error as NSError {
//            // Needs better error handling
//            print(error.localizedDescription)
//        }
//        
//        // Plays sound
//        sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("alarm", ofType: "mp3")!)
//        do {
//            // Removed deprecated use of AVAudioSessionDelegate protocol
//            
//            audioPlayer = try AVAudioPlayer(contentsOfURL: self.sound)
//        } catch {
//            print("There was an error loading the song.")
//        }
//        audioPlayer.play()
//

    }

    
    func spotifyUserCheck() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {// Session available
            // print session
            //print(sessionObj)
            
            print("Already Logged in ")
            // print session
            let sessionObjectData = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionObjectData) as! SPTSession
            print(sessionObj)
            
            if !session.isValid(){
                print("Session invalid.")
            } else {
                self.playUsingSession(session)
            }

        } else {
            print("New User")
            self.performSegueWithIdentifier("newUser", sender: nil)
        }
        
    }
    // Function relative to Spotify checking
    // Spotify
    func playUsingSession(session: SPTSession){
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self
        }
        
        player?.loginWithSession(session, callback: {(error: NSError!) -> Void in
            
            if error != nil {
                print("Session Login error")
            }
            
            self.useLoggedInPermissions()
        })
    }
    
    // Manages songs to be played
    func useLoggedInPermissions() {
        // Custom track
        let spotifyURI = "spotify:track:31nhn90QfKRPb1SzAVgJtz"
        // Plays selected song
        player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
        
    }

    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("PlaybackStatus")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didSeekToOffset offset: NSTimeInterval) {
        print("SeekToOffset")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) {
        print("ChangedVolume")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus isShuffled: Bool) {
        print("ChangedShuffleStatus")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus isRepeated: Bool) {
        print("ChangedRepeatStatus")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        print("ChangedToTrack")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        print("FailToPlayTrack")
    }
    
    func audioStreamingDidSkipToNextTrack(audioStreaming: SPTAudioStreamingController!) {
        print("NextTrack")
    }
    
    func audioStreamingDidSkipToPreviousTrack(audioStreaming: SPTAudioStreamingController!) {
        print("PreviousTrack")
    }
    
    func audioStreamingDidBecomeActivePlaybackDevice(audioStreaming: SPTAudioStreamingController!) {
        print("ActivePlaybackDevice")
    }
    
    func audioStreamingDidBecomeInactivePlaybackDevice(audioStreaming: SPTAudioStreamingController!) {
        print("InactivePlaybackDevice")
    }
    
    func audioStreamingDidLosePermissionForPlayback(audioStreaming: SPTAudioStreamingController!) {
        print("DidLosePermissionForPlayback")
    }
    
    func audioStreamingDidPopQueue(audioStreaming: SPTAudioStreamingController!) {
        print("DidPopQueue")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        // Track Info
        let trackName = audioStreaming.currentTrackMetadata[SPTAudioStreamingMetadataTrackName] as! String
        let trackAlbum = audioStreaming.currentTrackMetadata[SPTAudioStreamingMetadataAlbumName] as! String
        let trackArtist = audioStreaming.currentTrackMetadata[SPTAudioStreamingMetadataArtistName] as! String
        let trackDuration = audioStreaming.currentTrackMetadata[SPTAudioStreamingMetadataTrackDuration]
        
        // Music Info Center
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : trackArtist, MPMediaItemPropertyAlbumTitle : trackAlbum, MPMediaItemPropertyTitle : trackName, MPMediaItemPropertyPlaybackDuration: trackDuration!, MPNowPlayingInfoPropertyPlaybackRate : 1]
        
        print(trackName)
        print(trackAlbum)
        print(trackArtist)
        print("StartedPlayingTrack")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        print("StoppedPlayingTrack")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
