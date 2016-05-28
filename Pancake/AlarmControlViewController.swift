//
//  AlarmControlViewController.swift
//  Pancake
//
//  Created by Angel Vazquez on 5/27/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit


class AlarmControlViewController: UIViewController{
    
    // Music 
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackAlbum: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    
    var player:SPTAudioStreamingController?
    var session: SPTSession?
    var backgroundImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBlurredBackgroundImage()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlarmControlViewController.updateTrackInfo(_:)), name: "didStartPlaying", object: nil)
    }
    
    func addBlurredBackgroundImage() {
        // Create new Background View
        let backgroundImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = backgroundImage
        
        // Blur effect
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(frame: UIScreen.mainScreen().bounds)
        blurEffectView.effect = blurEffect
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.insertSubview(backgroundImageView, atIndex: 0)
        self.view.insertSubview(blurEffectView, atIndex: 0)
    }
    
    
    func updateTrackInfo(notification: NSNotification) {
//        let newTrackName = notification.userInfo!["SongName"] as! String
//        let newTrackAlbum = notification.userInfo!["SongAlbum"] as! String
//        let newTrackArtist = notification.userInfo!["SongArtist"] as! String
//        
//        trackName.text = newTrackName
//        trackAlbum.text = newTrackAlbum
//        trackArtist.text = newTrackArtist
        
        //print(newTrackName)
    }

    @IBAction func stopAlarm(sender: AnyObject) {
        player?.setIsPlaying(false, callback: nil)
        player?.stop(nil)
    }
    
    @IBAction func snoozeAlarm(sender: AnyObject) {
        
    }
    
    
    @IBAction func continueToDashboard(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}
