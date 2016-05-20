//
//  SpotifyPlaylistCollectionViewController.swift
//  SpotifyDemo
//
//  Created by Angel Vazquez on 3/5/16.
//  Copyright © 2016 Angel Vázquez. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

private let reuseIdentifier = "PlaylistCell"


class SpotifyPlaylistCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var player = SPTAudioStreamingController?()
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    
    // Album Artwork
    var artWorkAvailable = false
    
    // Spotify Playlists
    var numberOfPlaylists = 0
    var playlistTitles = [String]()
    var currentSession: SPTSession?
    var playlistArtWork = [UIImage]()
    var amountOfSongs = [Int]()
    var playlistURI = [NSURL]()
    var debugNumber = 0
    
    // Alarm info 
    var alarmTitle = ""
    var alarmTime = ""
    var alarmDays = ""
    var alarmMeri = ""
    var selectedDates = [String]()
    var hoursForAlarm = 0
    var minutesForAlarm = 0
    var playURI:String?
    
    // Used to fetch alarms from CoreData
    var alarms = [NSManagedObject]()
    
    @IBOutlet weak var playlistCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        loginWithSpotifySession(currentSession!)

        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.fetchData()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func success(sender: AnyObject) {
        
//        for i in 0 ..< selectedDates.count {
//            self.scheduleNotification(dayOfTheWeek(selectedDates[i]), hour: self.hoursForAlarm, minute: self.minutesForAlarm)
//        }
        
        // Saves new alarm
        if self.validateAlarm() {
            print(self.alarmExists())
            self.saveAlarm(alarmTitle, time: alarmTime, days: alarmDays, meri: alarmMeri, playlistURI: playURI!)
        }
        

    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        
        print("Application failed to login.")
        
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        
        //loginWithSpotifySession(session)
        print(session)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("Did cancel login.")
    }
    
    private
    
    func loginWithSpotifySession(session: SPTSession) {
        // .0 is NSError .1 is SPTListPage
        // listPage contains playlists
        // listPage is an array of playlists
        //setupSpotifyPlayer()
        // Callback Method that gets number of playlist that user has
        let callBack: SPTRequestCallback = { playlists -> Void in
            
            if (playlists.0 != nil) {
                print(playlists.0)
            }
            
            // Page 1 of playlists
            let listPage: SPTListPage = playlists.1 as! SPTListPage
            
            
            // Array that will hold playlists
            let playlist = NSMutableArray()
            
            // Sets the number of playlist user has
            self.numberOfPlaylists = listPage.items.count
            
            // Method to simplify Playlist data
            self.convertPlaylists(listPage, arrayOfPlaylistSnapshots: playlist, positionInListPage: 0, withSession: session)
            
            print(" Playlist info: \(listPage.items[0])")
        }
        
        // Gets playlists under user that started session (Current User)
        SPTPlaylistList.playlistsForUserWithSession(session, callback: callBack)
    }
    
    // Converts Playlist to PlaylistSnapShot
    func convertPlaylists(playlistPage: SPTListPage, arrayOfPlaylistSnapshots playlist:NSMutableArray, positionInListPage position: NSInteger, withSession session: SPTSession) {
    
        if (playlistPage.items.count > position) {
            
            let callBack: SPTRequestCallback = { playablePlaylist -> Void in
                
                let playablePlaylistSnapshot = playablePlaylist.1 as! SPTPlaylistSnapshot
                
                if (playablePlaylist.0 != nil){
                    print("Error getting playlist.")
                    return
                }
                
                playlist.addObject(playablePlaylistSnapshot)
                //print(playlist[position])
                self.convertPlaylists(playlistPage, arrayOfPlaylistSnapshots: playlist, positionInListPage: position + 1, withSession: session)
            }
            
            let userPlaylist: SPTPartialPlaylist = playlistPage.items[position] as! SPTPartialPlaylist
            SPTPlaylistSnapshot.playlistWithURI(userPlaylist.uri, session: session, callback: callBack)
            
        } else {
            // Manages all playlist info
            print(playlist)
            self.getPlaylistInfo(playlist, withSession: session)
        }
    }
    
    func getPlaylistInfo(playlists: NSMutableArray, withSession session: SPTSession){

        // Holds playst title and uri
        for i in 0...playlists.count-1 {
            // Gets the title of the Current Playlist in cycle
            let currentPlaylistTitle = playlists[i].name!
            // Gets the uri of the Current Playlist in cycle
            let currentPlaylistURI = playlists[i].uri
            // Gets the number of songs of the Current Playlist in cycle
            let currentPlaylistNumberOfSongs = playlists[i].tracksForPlayback().count
            
            // Adds fetched Data to corresponding arrays
            self.playlistTitles.append(currentPlaylistTitle)
            self.playlistURI.append(currentPlaylistURI)
            self.amountOfSongs.append(currentPlaylistNumberOfSongs)
        }
        
        // Used for getting album artwork
        for i in 0...playlists.count-1 {
            // First Playlist
            let currentPlaylist = playlists[i] as! SPTPartialPlaylist
            
            // URL for the Album Artwork
            let playlistArtWorkURL = currentPlaylist.largestImage.imageURL
            
            // Data in AlbumArtwork
            let albumArtWorkData = NSData(contentsOfURL: playlistArtWorkURL)
            let localAlbumArtwork = UIImage(data: albumArtWorkData!)
            
            // Adds Images to array
            playlistArtWork.append(localAlbumArtwork!)
        
            // If all images are now in array - reloadData in CollectionView
            if (i == numberOfPlaylists-1){
                self.artWorkAvailable = true
                self.playlistCollectionView.reloadData()
                
                // Stop progress wheel
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                    })
                    
                })
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return numberOfPlaylists
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: SpotifyPlaylistCellCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SpotifyPlaylistCellCollectionViewCell
    
        // Configure Playlist Artwork
        if (self.artWorkAvailable == false){
            cell.albumArtwork.backgroundColor = UIColor.whiteColor()
            print("Nil artwork.")
        } else {
            // Sets correct Album Artwork and Playlist Title
            cell.albumArtwork.image = self.playlistArtWork[indexPath.row]
            cell.playlistTitle.text = playlistTitles[indexPath.row]
            
            // Handles Plural of Song
            if(self.amountOfSongs[indexPath.row] == 1){
                cell.numberOfSongs.text = "\(self.amountOfSongs[indexPath.row]) song"
            } else {
                cell.numberOfSongs.text = "\(self.amountOfSongs[indexPath.row]) songs"
            }
            
        }
        
        
        
        return cell
    }
    
    // Sets the size of the cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        // Adjusts cell size so that only 3 cells fit per row
        let cellSize = (UIScreen.mainScreen().bounds.size.width / 2.0) - 15
        
        // Returns size of cell - Square
        return CGSize(width: cellSize, height: cellSize + 70)
        
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cellImageView = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(502)
        let playlistTitle = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(503)
        let numberOfSongsInPlaylist = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(504);
        let checkmark = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(701)
        
        // Make background darker and show checkmark
        playlistTitle!.alpha = 0.5
        numberOfSongsInPlaylist!.alpha = 0.5
        cellImageView?.alpha = 0.5
        checkmark?.hidden = false

        
        // Plays selected Album
        //self.playPlaylist(indexPath.row)
        playURI = "\(self.playlistURI[indexPath.row])"
        //print("Row \(self.playlistURI[indexPath.row]) selected.")
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cellImageView = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(502)
        let playlistTitle = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(503)
        let numberOfSongsInPlaylist = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(504);        let checkmark = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(701)
        
        playlistTitle!.alpha = 0.5
        numberOfSongsInPlaylist!.alpha = 0.5
        cellImageView?.alpha = 1
        checkmark?.hidden = true
    }
    // MARK: - Alarm setup
    
    // Manages notifications
    func scheduleNotification(dayOfWeek: Int, hour: Int, minute: Int) {
        print("Schedule Notification")
        
        // Fires alarm every Sunday at selected hour
        let gregCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let dateComponent = gregCalendar?.components([NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Weekday], fromDate: NSDate())
        
        // Set week day for recurring alarm
        dateComponent?.weekday = dayOfWeek
        dateComponent?.hour = hour
        dateComponent?.minute = minute
        
        let dd = UIDatePicker()
        dd.setDate((gregCalendar?.dateFromComponents(dateComponent!))!, animated: true)
        
        // Sends Alarm notification - You need to wake up now
        let alarmNotification = UILocalNotification()
        alarmNotification.fireDate = dd.date
        alarmNotification.alertBody = alarmTitle
        alarmNotification.alertAction = "OK"
        alarmNotification.userInfo = ["CustomField": "Woot"]
        UIApplication.sharedApplication().scheduleLocalNotification(alarmNotification)
        
        
    }

    // Returns date of the week
    func dayOfTheWeek(nameOfDay: String) -> Int {
        
        var dayOfTheWeekInt = 0
        
        switch nameOfDay {
        case "SUN":
            dayOfTheWeekInt = 1
        case "MON":
            dayOfTheWeekInt = 2
        case "TUE":
            dayOfTheWeekInt = 3
        case "WED":
            dayOfTheWeekInt = 4
        case "THU":
            dayOfTheWeekInt = 5
        case "FRI":
            dayOfTheWeekInt = 6
        case "SAT":
            dayOfTheWeekInt = 7
        default:
            print("Default")
        }
        
        
        return Int(dayOfTheWeekInt)
    }

    // MARK: - CoreData
    // Manages Alarm save to CoreData
    func saveAlarm(title: String, time: String, days: String, meri: String, playlistURI: String) {
        
        // Application Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Manages CoreData
        let managedContext = appDelegate.managedObjectContext
        // Entity described in data model
        let entity = NSEntityDescription.entityForName("Alarm", inManagedObjectContext: managedContext)
        
        // New Alarm
        let alarm = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        // Setups Alarm properties
        alarm.setValue(title, forKey: "title")
        alarm.setValue(time, forKey: "time")
        alarm.setValue(meri, forKey: "meri")
        alarm.setValue(days, forKey: "days")
        alarm.setValue(playURI, forKey: "playURI")
        
        // Saves alarm if there are no errors
        do {
            try managedContext.save()
            // Used for debugging purposes only
            //print("Success saving date.")
            let savedAlarmAlert = JSSAlertView()
            savedAlarmAlert.show(self,
                                 title: "Success!",
                                 text: "Your alarm was saved succesfully\n",
                                 buttonText: "OK",
                                 color: UIColor.whiteColor())
            
            // Goes back to Dashboard when OK is pressed
            savedAlarmAlert.addAction(goBackToDashboard)
        } catch let error as NSError {
            // Displays error message in console
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // Checks if user enter all info needed to save alarm
    func validateAlarm() -> Bool{
        
        let alarmExistsFlag = self.alarmExists()
        
        if ((self.playURI == nil)){
            let incompleteInfoAlert = JSSAlertView()
            incompleteInfoAlert.show(self,
                                     title: "Oops...",
                                     text: "Please select a playlist for the alarm",
                                     buttonText: "OK",
                                     color: UIColor.whiteColor())
            return false
        } else if (alarmExistsFlag == true) {
            let alarmAlreadyExistsAlert = JSSAlertView()
            alarmAlreadyExistsAlert.show(self, title: "Oops...",
                                         text: "An alarm at that same time already exists; Please select another time.",
                                         buttonText: "OK",
                                         color: UIColor.whiteColor())
            return false
        }
        return true
    }

    func alarmExists() -> Bool{
        if (!alarms.isEmpty){
            for i in 0..<alarms.count {
                let alarm = alarms[i]
                let alarmFireTime = alarm.valueForKey("time") as! String
                let alarmMeridian = alarm.valueForKey("meri") as! String
                print(alarmFireTime)
                
                if (alarmFireTime.rangeOfString(self.alarmTime) != nil && alarmMeridian.rangeOfString(self.alarmMeri) != nil) {
                    return true
                }
            }

        }
        
        return false
    }
    
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
    // Goes to Main Screen - Dashboard
    func goBackToDashboard() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }


}
