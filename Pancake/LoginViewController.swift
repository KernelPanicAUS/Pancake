//
//  LoginViewController.swift
//  Pancake
//
//  Modified by Angel Vázquez
//
//  Created by Rudy Rosciglione on 28/12/15.
//  Copyright © 2015 Rudy Rosciglione. All rights reserved.
//

import UIKit
import MediaPlayer

class LoginViewController: UIViewController{
    
    let kClientID = "eb68da6b0f3c4589a25e1c95bd3699f3"
    let kCallbackURL = "pancakeapp://callback"
    let kTokenSwapUrl = "http://localhost:1234/swap"
    let kTokenRefreshServiceUrl = "http://localhost:1234/refresh"
    let auth = SPTAuth.defaultInstance()


    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet var loginViewCrontoller: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register to be notified when the user has logged in successfully in order to dismiss the login view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismiss", name: "loginSuccessful", object: nil)

        // If session data is available, dismiss the loginViewController
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {// Session available
            // print session
            print(sessionObj)
        }
        
    }
    
    func dismiss() {
        print("Should dismiss loginViewController");
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        auth.clientID = kClientID
        auth.requestedScopes = [SPTAuthStreamingScope]
        auth.redirectURL = NSURL(string:kCallbackURL)
        //auth.tokenSwapURL = NSURL(string:kTokenSwapUrl)
        //auth.tokenRefreshURL = NSURL(string:kTokenRefreshServiceUrl)
        
        //let loginURL = NSURL(string: "https://accounts.spotify.com/authorize?client_id=eb68da6b0f3c4589a25e1c95bd3699f3&scope=streaming&redirect_uri=pancakeapp%3A%2F%2Fcallback&nosignup=true&nolinks=true&response_type=token")
        let loginURL = auth.loginURL
        print(loginURL)
        
        UIApplication.sharedApplication().openURL(loginURL!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
