//
//  ViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 28/12/15.
//  Copyright © 2015 Rudy Rosciglione. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var session = SPTSession()
    
    @IBOutlet weak var backgroundProfilePicture: UIImageView!
    @IBOutlet weak var smallProfilePicture: UIImageView!
    
    @IBOutlet weak var currentUserName: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        smallProfilePicture.layer.masksToBounds = true
        smallProfilePicture.layer.cornerRadius = smallProfilePicture.layer.bounds.size.height / 2
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let callBack: SPTRequestCallback = { userData -> Void in
        
            if (userData.0 != nil) {
                print("Error loading user info. \(userData.0)")
            }
            
            self.currentUserName.text = userData.1.displayName as String
            let bigProfilePicture = userData.1.largestImage as SPTImage
            
            self.setProfilePicture(bigProfilePicture.imageURL)
            
            
        }
        
        SPTUser.requestCurrentUserWithAccessToken(session.accessToken, callback: callBack)
        
        
    }

    func setProfilePicture(imageURL: NSURL) {
        let profilePictureData = NSData(contentsOfURL: imageURL)
        let profilePictureImage = UIImage(data: profilePictureData!)
        
        smallProfilePicture.image = profilePictureImage
        backgroundProfilePicture.image = profilePictureImage
        self.blurBackground()
    }
    
    func blurBackground() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundProfilePicture.frame
        
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.insertSubview(blurEffectView, atIndex: 1)
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        print("Cancel")
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

