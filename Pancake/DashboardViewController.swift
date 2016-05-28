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
import AVKit
import SystemConfiguration

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
    var needsSessionRefresh = false
    var sessionIsRefreshing = false
    var session = SPTSession()
    let soundActivator = MMPDeepSleepPreventer()
    
    // Used to fetch alarms from CoreData
    var alarms = [NSManagedObject]()
    
    // Used to play alarm only once
    var canPlayAlarmFlag = true
    var lastAlarmTime = "last"
    
    // New User Flag
    var newUser = false
    
    // Refreshing tokens flag
    var refreshingTokens = false
    
    // Main timer
    var mainTimer = NSTimer?()
    
    // Network reachability
    var reachability: Reachability?
    
    var isReachable:Bool?
    
    var starBG: UIImage?
    
    var nameOfSong: String?
    var songAlbum: String?
    var songArtist: String?
    
    var isDisplayingSongInfo: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starBG = UIImage(named: "starBG")
        
        // Reachability code
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DashboardViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        // Spotify is checking if the user is logged in
        self.spotifyUserCheck()
        
        // Start playing silent.
        soundActivator.startPreventSleep()
        
        // Permission for notification
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Used for music controls
         UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        // Fast update time
        self.timeUpdate()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        // Update Time Periodically
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(DashboardViewController.timeUpdate), userInfo: nil, repeats: true)
            
        // Fetches Alarms.
        self.fetchData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
//        // Initialize Player after first log in
//        if (player == nil && newUser == true){
//            // Used for debugging purposes only.
//            //print("Player nil")
//            self.playUsingSession(auth.session)
//        } else {
//            self.spotifyUserCheck()
//        }
//        
//        
    }
    
    // MARK: - Timer
    
    // Updates Time and all its elements
    func timeUpdate(){
        // Used for debugging purposes only.
        //print("New session saved succesfully.")
        if session.isValid() {
            sessionIsRefreshing = false
        }
        
        // Used to leave user logged in
        if (!session.isValid() && sessionIsRefreshing == false) {
            self.renewToken(session)
        }
        
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
        
        // When last alarm finished playing - Let other alarms play
        if (lastAlarmTime.rangeOfString(timeDisplay.text!) == nil) {
            canPlayAlarmFlag = true
        }
        
        // Checks alarm time with current time - Determines if it has to play or not.
        self.timeToPlayAlarm()
    }
    
    // MARK: - Alarm
    // Check if it is time for alarm
    func timeToPlayAlarm() {
        // Check only if there are alarms saved
        if (!alarms.isEmpty) {
            // Verify if alarm can be played - Used to play only once
            if (canPlayAlarmFlag == true) {
                for i in 0...alarms.count-1 {
                    // Gets current alarm time
                    let alarm = alarms[i]
                    let alarmTitle = alarm.valueForKey("title") as! String
                    let alarmTime = alarm.valueForKey("time") as! String
                    let alarmMeri = alarm.valueForKey("meri") as! String
                    let playlistURI = alarm.valueForKey("playURI") as! String
                    // If Current time is = to Alarm time, play alarm
                    if (alarmTime.rangeOfString(timeDisplay.text!) != nil && alarmMeri.rangeOfString(meridiemDisplay.text!) != nil) {
                       
                        // Play alarm only once
                        canPlayAlarmFlag = false
                        
                        // Used for debugging purposes only
                        print("Alarm must be played.")
                        
                        // Check the last alarm played in order to reactivate flag
                        lastAlarmTime = alarmTime
                        
                        // Trigger notification
                        self.alarmNotification(alarmTitle)
                        
                        // Play spotify music
                        self.useLoggedInPermissions(playlistURI)
                        
                        // Show Music Controller View
                        self.performSegueWithIdentifier("MusicPlayerSegue", sender: nil)
                    }
                }

            }
        }
    }
    
    // MARK: - Spotify
    
    // Checks if user is freshly logged in
    func spotifyUserCheck() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Session available
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            // print session
            //print(sessionObj)
            
            print("Already Logged in ")
            newUser = false

            // print session
            let sessionObjectData = sessionObj as! NSData
            session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionObjectData) as! SPTSession
            print(sessionObj)
            
            // If session is not valid
            if !session.isValid() && (isReachable!){
                print("Session invalid. Needs token Refresh.")
                needsSessionRefresh = true
                self.renewToken(session)
            } else {
                self.playUsingSession(session)
            }

        } else {
            print("New User")
            newUser = true
            self.performSegueWithIdentifier("newUser", sender: nil)
        }
        
    }
    
    // Initializes and Setups Spotify music player.
    func playUsingSession(session: SPTSession){
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player!.playbackDelegate = self
            player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
            
            // Shuffles between songs in playlists
            player?.shuffle = true

            let callBack: SPTErrorableOperationCallback = { error -> Void in
                if (error != nil) {
                    print("Error with bitrate.")
                }
            
            }
            player?.setTargetBitrate(SPTBitrate.Low, callback: callBack)
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
    func useLoggedInPermissions(playlistURI: String) {
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
        // let spotifyURI = "spotify:user:spotify:playlist:5HEiuySFNy9YKjZTvNn6ox" // Chill Vibes Playlist
        
        let callback: SPTErrorableOperationCallback = { result -> Void in
        
            print("Callback in.")
            
            // Snoozes or Stops alarm - Very early version
//            stopMusicAlert.show(self,
//                                title: "Wake up",
//                                text: "Common, you can do it!",
//                                buttonText: "Im awake",
//                                cancelButtonText: "Snooze",
//                                color: UIColor.whiteColor())
//            
//            stopMusicAlert.addAction({
//                print("Stop")
//                self.player?.setIsPlaying(false, callback: nil)
//                self.player!.stop(nil)
//            })

        
            if result != nil {
                print("What happened")
                // Snoozes or Stops alarm - Very early version
                stopMusicAlert.show(self,
                                    title: "Error",
                                    text: "\(result)",
                                    buttonText: "Im awake",
                                    cancelButtonText: "Snooze",
                                    color: UIColor.whiteColor())
                
                stopMusicAlert.addAction({
                    print("Stop")
                    self.player!.stop(nil)
                })

            }
            
        }
        
        // Starts playing the music
        player!.playURIs([NSURL(string: playlistURI)!], withOptions: nil, callback: callback)
        
    }
    
    // Notification setup
    func alarmNotification(alarmName: String) {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings?.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "We dont have permission to schedule notifications.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate.init(timeIntervalSinceNow: 0)
        notification.alertTitle = alarmName
        notification.alertBody = alarmName
        notification.alertAction = "OK"
        notification.userInfo = ["CustomField": "Woot"]

        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
        let currentTrackURI = audioStreaming.currentTrackURI
        let callback:SPTRequestCallback = {result -> Void in
        
            let currentSong = result.1 as! SPTTrack
            let trackName = currentSong.name
            let albumName = currentSong.album.name
            guard let artist = currentSong.artists.first as? SPTPartialArtist else {
                print("No artist name provided.")
                return
            }
            let artistName = artist.name
            let duration = currentSong.duration
            let imageURL: NSURL = currentSong.album.smallestCover.imageURL
            let image = imageFromURL("\(imageURL)")
            //print(image)
            print(trackName)
            print(albumName)
            print(artistName)
            
//            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle : trackName, MPMediaItemPropertyAlbumTitle : albumName, MPMediaItemPropertyArtist : artistName, MPMediaItemPropertyPlaybackDuration : duration]
            
            let musicInfoDictionary: [NSObject : AnyObject]  = ["SongName" : trackName, "SongAlbum" : albumName, "SongArtist" : artistName]
            
            // Show Now Playing info
            TSMessage.showNotificationInViewController(self, title: trackName,
                                                       subtitle: artistName,
                                                       image: image,
                                                       type: TSMessageNotificationType.Message,
                                                       duration: duration,
                                                       callback: nil,
                                                       buttonTitle: "Stop",
                                                       buttonCallback: {
                                                        self.player?.setIsPlaying(false, callback: nil)
                                                        self.player?.stop(nil)},
                                                       atPosition: TSMessageNotificationPosition.Bottom, canBeDismissedByUser: false)
            
            
            // Notify Alarm Controller
            NSNotificationCenter.defaultCenter().postNotificationName("didStartPlaying", object: nil, userInfo: musicInfoDictionary)
            
        }
        
        SPTTrack.trackWithURI(currentTrackURI, session: session, callback: callback)

        print("StartedPlayingTrack")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        // Music Info Center
        // Clears all data in NowPlayingInfoCenter
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
        print("StoppedPlayingTrack")
        //soundActivator.startPreventSleep()
        //print("soundActivator active")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Session refresh
    // Renews invalid session
    func renewToken(invalidSession: SPTSession){
        
        sessionIsRefreshing = true
        // Displays in console that tokens are being refreshed
        print("Refreshing Token")
        
        // Sets the correct URL's for Token Refresh service.
        auth.tokenSwapURL = NSURL(string: kTokenSwapUrl)
        auth.tokenRefreshURL = NSURL(string: kTokenRefreshServiceUrl)
        
        // Renewing session
        auth.renewSession(invalidSession, callback: {(error, session) -> Void in
            
            // Perform if there is no error renewing session
            if error == nil {
                
                //if (self.refreshingTokens == false) {
                    // Save new session
                    self.saveNewSession(session)
                    // Get player ready
                    self.playUsingSession(session)
                    print("The renewed Spotify session is", session)
                    print("The renewed canonical user name in the session is", session.canonicalUsername)
                    self.refreshingTokens = true
                    print("Refreshing tokens = \(self.refreshingTokens)")
                //}
                
            // If there is an error renewing session
            } else {
                
                // Needs better error handling
                print ("The problem with the renewal session is", error)
            }
        })
    }
    
    // Replace invalid session with valid session using CoreData
    func saveNewSession(newSession: SPTSession) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(newSession)
        
        userDefaults.setObject(sessionData, forKey: "SpotifySession")
        userDefaults.synchronize()
        
    }

    
    //MARK: - Control Music
    // Controls music
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlPause {
                print("Pause")
                if player?.isPlaying == true {
                    player?.setIsPlaying(false, callback: nil)
                    player?.stop(nil)
                }
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
    
    @IBAction func showUserInfo(sender: AnyObject) {
        if (isReachable == true) {
            self.performSegueWithIdentifier("UserSegue", sender: nil)
        } else {
            self.showNetworkConnectionErrorNotification()
        }
    }
    
    @IBAction func createNewAlarm(sender: AnyObject) {
        if (isReachable == true) {
            self.performSegueWithIdentifier("HomeScreenSegue", sender: nil)
        } else {
            self.showNetworkConnectionErrorNotification()
        }
    }
    
    func showNetworkConnectionErrorNotification() {
        TSMessage.showNotificationWithTitle("No internet connection.", type: TSMessageNotificationType.Error)

    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ViewAlarmsSegue") {
            mainTimer?.invalidate()
            mainTimer = nil
            // Invalidate timer so that App doesn't crash when an alarm is deleted
            print("View Alarms segue")
            
        } else if (segue.identifier == "UserSegue") {
            let userViewController = segue.destinationViewController as! ViewController
            userViewController.session = session
            userViewController.player = player
        } else if (segue.identifier == "HomeScreenSegue") {
            let createAlarmViewController = segue.destinationViewController as! CreateNewViewController
            createAlarmViewController.backgroundImage = starBG!
        } else if (segue.identifier == "MusicPlayerSegue") {
            let alarmControlViewController = segue.destinationViewController as! AlarmControlViewController
            
            alarmControlViewController.player = self.player
            alarmControlViewController.session = self.session
            alarmControlViewController.backgroundImage = starBG
        }
    }
    
    //MARK: - Reachability
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            isReachable = true
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            isReachable = false
        }
    }
    


}
