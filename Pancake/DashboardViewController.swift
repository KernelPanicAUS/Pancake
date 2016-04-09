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
    let kTokenSwapUrl = "https://pancake-spotify-token-swap.herokuapp.com/swap"
    let kTokenRefreshServiceUrl = "https://pancake-spotify-token-swap.herokuapp.com/refresh"
    
    // Used to fetch alarms from CoreData
    var alarms = [NSManagedObject]()
    
    // Used to play alarm only once
    var canPlayAlarmFlag = true
    var lastAlarmTime = "last"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Spotify is checking if the user is logged in
        self.spotifyUserCheck()
        
        // Update Time Periodically = _ Stands for timer :P
        let _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(DashboardViewController.timeUpdate), userInfo: nil, repeats: true)
        
        // Permission for notification
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Deprecated code. Left here until final version is released.
        //EZSwipe
        //presentViewController(EZSwipeController(), animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // Fetches Alarms.
        self.fetchData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.becomeFirstResponder()
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        // Initialize Player after first log in
        if (player == nil){
            // Used for debugging purposes only. 
            //print("Player nil")
            self.playUsingSession(auth.session)
        } else {
            // Used for debugging purposes only
            //print("Player ok")
        }
    }
    
    // MARK: - Timer
    
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
        
        // When last alarm finished playing - Let other alarms play
        if (lastAlarmTime.rangeOfString(timeDisplay.text!) == nil) {
            canPlayAlarmFlag = true
            
            // Used for debugging purposes only. 
            //print(canPlayAlarmFlag)
        }
        
        // Checks alarm time with current time - Determines if it has to play or not.
        self.timeToPlayAlarm()
    }
    
    // MARK: - Alarm
    
    // Check if it is time for alarm
    func timeToPlayAlarm() {
        
        // Check only if there are alarms saved
        if (alarms.isEmpty == false) {
            // Verify if alarm can be played - Used to play only once
            if (canPlayAlarmFlag == true) {
                for i in 0...alarms.count-1 {
                    // Gets current alarm time
                    let alarm = alarms[i]
                    let alarmTime = alarm.valueForKey("time") as! String
                    let alarmMeri = alarm.valueForKey("meri") as! String
                    // If Current time is = to Alarm time, play alarm
                    if (alarmTime.rangeOfString(timeDisplay.text!) != nil && alarmMeri.rangeOfString(meridiemDisplay.text!) != nil) {
                       
                        // Play alarm only once
                        canPlayAlarmFlag = false
                        
                        // Used for debugging purposes only
                        //print("Alarm must be played.")
                        
                        // Check the last alarm played in order to reactivate flag
                        lastAlarmTime = alarmTime
                        
                        // Used for debugging purposes only
                        //print(canPlayAlarmFlag)
                        
                        // Play spotify music
                        self.useLoggedInPermissions()
                    }
                }

            }
        }
    }
    
    // MARK: - Spotify
    
    // Checks if user is freshly logged in
    // Needs work with refresh tokens for final app
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
            
            // If session is not valid
            if !session.isValid(){
                print("Session invalid. Needs token Refresh.")
                self.renewToken(session)
            } else {
                self.playUsingSession(session)
            }

        } else {
            print("New User")
            self.performSegueWithIdentifier("newUser", sender: nil)
        }
        
    }
    
    // Initializes and Setups Spotify music player.
    func playUsingSession(session: SPTSession){
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player!.playbackDelegate = self
            player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        }
        
        player?.loginWithSession(session, callback: {(error: NSError!) -> Void in
            
            // Handles player error
            // Needs better error handling
            if error != nil {
                print("Session Login error")
            }
            
        })
    }
    
    // Manages songs/playlist to be played
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
        
        // Plays custom playlist
        let spotifyURI = "spotify:user:spotify:playlist:5HEiuySFNy9YKjZTvNn6ox" // Chill Vibes Playlist
        
        // Starts playing the music
        player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
        
        // Snoozes or Stops alarm - Very early version
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
    // Renews invalid session
    func renewToken(invalidSession: SPTSession){
        
        // Displays in console that tokens are being refreshed
        print("Refreshing Token")
        
        // Sets the correct URL's for Token Refresh service.
        auth.tokenSwapURL = NSURL(string: kTokenSwapUrl)
        auth.tokenRefreshURL = NSURL(string: kTokenRefreshServiceUrl)
        
        // Renewing session
        auth.renewSession(invalidSession, callback: {(error, session) -> Void in
            
            // Perform if there is no error renewing session
            if error == nil {
                self.playUsingSession(session)
                print("The renewed Spotify session is", session)
                print("The renewed canonical user name in the session is", session.canonicalUsername)
                
            // If there is an error renewing session
            } else {
                
                // Needs better error handling
                print ("The problem with the renewal session is", error)
            }
        })
    }

    
    //MARK: - Control Music
    // Controls music
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlPause {
                print("Pause")
                player!.stop(nil)
            } else if (event!.subtype == UIEventSubtype.RemoteControlNextTrack) { 
                print("Next")
                
                // Goes to next song in the playlist
                // Needs better error handling.
                let callBack: SPTErrorableOperationCallback = { error -> Void in
                    
                    if (error != nil) {
                        print("There was an error: \(error)")
                    } else {
                        print("Playing next song.")
                    }
                }
                
                player!.skipNext(callBack)
            }
        }
    }
    
    // MARK: - CoreData
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


    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
