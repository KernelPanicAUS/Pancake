//
//  LoginViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 28/12/15.
//  Copyright © 2015 Rudy Rosciglione. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let kClientId = "eb68da6b0f3c4589a25e1c95bd3699f3"
    let kCallbackUrl = "pancakeapp://callback"
    let kTokenSwapUrl = "http://localhost:1234/swap"
    let kTokenRefreshServiceUrl = "http://localhost:1234/refresh"

    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet var loginViewCrontoller: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginViewCrontoller.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAfterFirstLogin", name: "loginSuccessFull", object: nil)

        let userDefaults = NSUserDefaults.standardUserDefaults()

        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {// Session available
            // print session
            print(sessionObj)
        }else{
            loginViewCrontoller.hidden = false
        }

    }
    
    func updateAfterFirstLogin () {
        loginViewCrontoller.hidden = true
        
    }
        

    @IBAction func loginWithSpotify(sender: AnyObject) {
        let auth = SPTAuth.defaultInstance()
        
        auth.clientID = kClientId
        auth.redirectURL = NSURL(string:kCallbackUrl)
//        auth.tokenSwapURL = NSURL(string:kTokenSwapUrl)
//        auth.tokenRefreshURL = NSURL(string:kTokenRefreshServiceUrl)
        auth.requestedScopes = [SPTAuthStreamingScope]
        
        let loginURL = auth.loginURL

        UIApplication.sharedApplication().openURL(loginURL)
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
