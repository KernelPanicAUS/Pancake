//
//  DashboardViewController.swift
//  Pancake
//
//  Modified by Angel Vázquez
//
//  Created by Rudy Rosciglione on 05/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class DashboardViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {

    // Alarm outlets
    @IBOutlet weak var imageTimeDisplay: UIImageView!
    @IBOutlet weak var userDailyMessage: UILabel!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var dateDisplay: UILabel!
    @IBOutlet weak var meridiemDisplay: UILabel!
    
    // Spotify
    var player = SPTAudioStreamingController?()
    let kClientID = "eb68da6b0f3c4589a25e1c95bd3699f3"
    let auth = SPTAuth.defaultInstance()
    let kCallbackURL = "pancakeapp://callback"
    
    // Used to fetch alarms from CoreData
    var alarms = [NSManagedObject]()
    var canPlayAlarmFlag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Spotify is checking if the user is login
        self.spotifyUserCheck()
        
        // Update Time Periodically = _ Stands for timer :P
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(DashboardViewController.timeUpdate), userInfo: nil, repeats: true)
        
        // Permission for notification
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Schedules notification
        //self.scheduleNotification()

        // Lets us play background music when screen is locked
        //let sleepPrevent = MMPDeepSleepPreventer()
        //sleepPrevent.startPreventSleep()
        
        //EZSwipe
        //presentViewController(EZSwipeController(), animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Fetches alarm data
        self.fetchData()
    }
    
    // Updates Time and all its elements
    func timeUpdate(){
        
        // Creates a custom Time format
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm"
       
        // Displays time in custom format "hh:mm"
        let now = NSDate()
        let formattedTime = timeFormatter.stringFromDate(now)
        
        // Prints day of the week
        //print("\(self.getDayOfWeekString(dayFormatter.stringFromDate(now)))")
        
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
        
        self.timeToPlayAlarm()
    }
    
    // Checks if alarm is going to play
    // Gets Alarms Stored in CoreData
    func fetchData() {
        // Application Delegate
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        // Manages CoreData
        let context:NSManagedObjectContext = appDel.managedObjectContext
        
        // Feteches saved alarms
        let fetchRequest = NSFetchRequest(entityName: "Alarm")
        do {
            try alarms = context.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not load data error: \(error), \(error.userInfo)")
        }
    }

    // Check if it is time for alarm
    func timeToPlayAlarm() {
        
        if (alarms.isEmpty == false) {
            if (canPlayAlarmFlag == true) {
                for (var i = 0; i < alarms.count; i+=1){
                    let alarm = alarms[i]
                    let alarmTime = alarm.valueForKey("time") as! String
                    //print(alarmTime)
                    if (alarmTime.rangeOfString(timeDisplay.text!) != nil) {
                        canPlayAlarmFlag = false
                        print("Alarm must be played.")
                        self.useLoggedInPermissions()
                    }
                }

            }
        }
    }
    
    // Manages notifications
    func scheduleNotification() {
               print("Schedule Notification")
        
        // Fires alarm every Sunday at selected hour
        let gregCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let dateComponent = gregCalendar?.components([NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Weekday], fromDate: NSDate())
        
        // Set week day for recurring alarm
        dateComponent?.weekday = 1
        dateComponent?.hour = 2
        dateComponent?.minute = 57
        
        let dd = UIDatePicker()
        dd.setDate((gregCalendar?.dateFromComponents(dateComponent!))!, animated: true)
        
        // Sends Alarm notification - You need to wake up now
        let alarmNotification = UILocalNotification()
        alarmNotification.fireDate = dd.date
        alarmNotification.alertBody = "Wake up"
        alarmNotification.alertAction = "OK"
        alarmNotification.userInfo = ["CustomField": "Woot"]
        UIApplication.sharedApplication().scheduleLocalNotification(alarmNotification)
        
        
    }
    
    func spotifyUserCheck() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Session available
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            // print session
            //print(sessionObj)
            
            print("Already Logged in ")
            // print session
            let sessionObjectData = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionObjectData) as! SPTSession
            print(sessionObj)
            
            if !session.isValid(){
                print("Session invalid.")
                self.loginWithSpotify()
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
            player!.playbackDelegate = self
            player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        }
        
        player?.loginWithSession(session, callback: {(error: NSError!) -> Void in
            
            if error != nil {
                print("Session Login error")
            }
            
            //et alarmTimer = NSTimer(fireDate: NSDate(timeIntervalSinceNow: 60), interval: 60, target: self, selector: "useLoggedInPermissions", userInfo: nil, repeats: false)
            //NSRunLoop.currentRunLoop().addTimer(alarmTimer, forMode: NSDefaultRunLoopMode)
            
        })
    }
    
    // Manages songs to be played
    func useLoggedInPermissions() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        // Alert used to stop Spotify Music
        let stopMusicAlert = JSSAlertView()
        
        // Custom track
        let spotifyURI = "spotify:track:7HzCxalzzYQOFb9a7Xs3j6"
        // Plays selected song
        player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
        
        stopMusicAlert.show(self,
            title: "Wake up",
            text: "Common, you can do it!",
            buttonText: "Im awake",
            cancelButtonText: "Snooze",
            color: UIColor.whiteColor())
        
        stopMusicAlert.addAction({
            print("Stop")
            self.player!.stop(nil)
        })

        
    }

    
    // MARK: - SPTAudioStreamingPlaybackDelegate
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
        // Music Info Center
        // Clears all data in NowPlayingInfoCenter
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
        print("StoppedPlayingTrack")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Session refresh
    // This is for debugging purposes only
    // Once refresh tokens are working this will not be needed.
    // Login with Spotify
    func loginWithSpotify() {
        auth.clientID = kClientID
        auth.requestedScopes = [SPTAuthStreamingScope]
        auth.redirectURL = NSURL(string:kCallbackURL)
        
        // This needs to be used for Demo purposes. When app is live we only need auth.loginURL
        //let loginURL = NSURL(string: "https://accounts.spotify.com/authorize?client_id=eb68da6b0f3c4589a25e1c95bd3699f3&scope=streaming&redirect_uri=pancakeapp%3A%2F%2Fcallback&nosignup=true&nolinks=true&response_type=token")
        let loginURL = auth.loginURL
        print(loginURL)
        
        UIApplication.sharedApplication().openURL(loginURL!)
        
    }
    
    //MARK: - Control Music
    // Controls music
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlPause {
                print("Pause")
                player!.stop(nil)
            }
        }
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
