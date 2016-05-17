//
//  AppDelegate.swift
//  Pancake
//
//  Modified by Angel Vázquez
//
//  Created by Rudy Rosciglione on 28/12/15.
//  Copyright © 2015 Rudy Rosciglione. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingPlaybackDelegate{
    
    // Spotify
    var player = SPTAudioStreamingController?()
    let kClientID = "eb68da6b0f3c4589a25e1c95bd3699f3"
    let auth = SPTAuth.defaultInstance()
    let kCallbackURL = "pancakeapp://callback"
    let kTokenSwapUrl = "https://pancake-spotify-token-swap.herokuapp.com/swap"
    let kTokenRefreshServiceUrl = "https://pancake-spotify-token-swap.herokuapp.com/refresh"
    var session = SPTSession()
    
    // Backendless
    let APP_ID = "B72ECBA0-7200-C279-FFD5-F5B7E7FC2000"
    let SECRET_KEY = "94F93C32-5C75-4B5A-FF05-AD0BDB13E800"
    let APP_VERSION = "v1"
    var backendless = Backendless.sharedInstance()
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Removes status bar
        application.statusBarHidden = true
        
        // Checks for Spotify User
        spotifyUserCheck()
        
        // Permission for notification
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        // Register for notifications
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        // Register for push notifications
        //UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        
        // Initial Backendless communication
        backendless.initApp(APP_ID, secret: SECRET_KEY, version: APP_VERSION)
        
        backendless.messaging.registerForRemoteNotifications()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if SPTAuth.defaultInstance().canHandleURL(url){
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error:NSError!, session: SPTSession!) -> Void in
                if error != nil {
                    print("===AUTHENTICATION ERROR===")
                    
                    // Displays a custom Alert if there is an error in the sign in process
                    self.showAlert()
                    
                    // Displays the error in console.
                    print(error)
                    return
                }
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                
                userDefaults.setObject(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                
                print("Login was successful");
                // Spotifiy session data has been received
                // Post notification to tell LoginViewController to be dismissed
                NSNotificationCenter.defaultCenter().postNotificationName("loginSuccessful", object: nil)
                
            })
            
        }
        
        return false
    }
    
    //MARK:- Spotify
    func spotifyUserCheck() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Session is available
        if let sessionObj: AnyObject = userDefaults.objectForKey("SpotifySession") {
            
            // Used for debugging purposes
            print("Already logged in. ")
            
            let sessionObjData = sessionObj as! NSData
            session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionObjData) as! SPTSession
            print(sessionObj)
            
            // Handles session validity
            if isSessionValid(session) == false {
                renewSession(session)
            } else {
                playUsingSession(session)
            }
            
            
        } else {
            print("New user")
            
        }
    }
    
    func playUsingSession(session: SPTSession) {
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self
            player?.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
            
            // Don't want same music every time don't we? ;)
            player?.shuffle = true
            
            let callback: SPTErrorableOperationCallback = { error -> Void in
                
                if error != nil {
                    print("Error adjusting bitrate.")
                }
            }
            
            player?.setTargetBitrate(SPTBitrate.Low, callback: callback)
        }
        
        player?.loginWithSession(session, callback: { error -> Void in
            
            if error != nil {
                print("Error login in with session.")
            }
        
        })
    }
    
    func playTrack() {
        
        let callback: SPTErrorableOperationCallback = { error -> Void in
            if error != nil {
                print("Error playing track.")
            }
        }

        player?.playURI(NSURL(string: "spotify:track:0LQsM0KYkSyCdN6TCo63vp"), callback: callback)
    }
    
    func playAlarm(completionHandler: (UIBackgroundFetchResult) -> Void) {
        if !session.isValid() {
            renewSession(session)
        }
        
        print("Play alarm.")
        
        playTrack()
        
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func renewSession(session: SPTSession) {
        auth.tokenSwapURL = NSURL(string: kTokenSwapUrl)
        auth.tokenRefreshURL = NSURL(string: kTokenRefreshServiceUrl)
        
        auth.renewSession(session, callback: { (error, session) -> Void in
        
            if error == nil {
                self.saveNewSession(session)
            } else {
                print("Error refreshing session.")
            }
            
        })
        
    }
    
    func saveNewSession(newSession: SPTSession) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(newSession)
        
        userDefaults.setObject(sessionData, forKey: "SpotifySession")
        userDefaults.synchronize()
    }
    
    func isSessionValid(session: SPTSession) -> Bool {
        if !session.isValid() {
            return false
        } else {
            return true
        }
    }
    
    //MARK:- SPTAudioStreamingPlaybackDelegate
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
            
            print(trackName)
            print(albumName)
            print(artistName)
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle : trackName, MPMediaItemPropertyAlbumTitle : albumName, MPMediaItemPropertyArtist : artistName, MPMediaItemPropertyPlaybackDuration : duration]
            
        }
        
        SPTTrack.trackWithURI(currentTrackURI, session: session, callback: callback)
        
        print("StartedPlayingTrack")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        // Music Info Center
        // Clears all data in NowPlayingInfoCenter
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
        print("StoppedPlayingTrack")
    }

    
    //MARK:- Application State
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Did enter background.")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background. let notification = UILocalNotification()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    //MARK:- Local Notification Setup
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("Did receive wake up notification")
    }
    
    //MARK:- RemoteNotification Setup
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Did register for remote notifications.")
        backendless.messaging.registerDeviceToken(deviceToken)
        
        // Used for debugging
        //self.retreiveDeviceRegistrationAsync(backendless.messaging.currentDevice().deviceId)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func retreiveDeviceRegistrationAsync(deviceID: String) {
        backendless.messaging.getRegistrationAsync(deviceID,
                                                   response:{ ( result : DeviceRegistration!) -> () in
                                                    print("DeviceRegistration = \(result)")},
                                                   error: { ( fault : Fault!) -> () in
                                                    print("Server reported an error: \(fault)")}
    )}

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        playAlarm(completionHandler)
        
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "eu.rudyrosciglione.Pancake" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Pancake", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Custom Alert
    
    func showAlert() {
        // Displays alert when there is an error
        let authErrorAlert = JSSAlertView()
        // Reference to LoginViewController
        let loginViewController = self.window?.rootViewController
        
        // Alert setup
        authErrorAlert.show(loginViewController!, title: "Oops...", text: "Looks like there was a login error Please try again later", buttonText: "OK", color: UIColorFromHex(0xe74c3c, alpha: 1))
        authErrorAlert.setTextTheme(.Light)
        
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

