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

class LoginViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate{
    
    let kClientID = "eb68da6b0f3c4589a25e1c95bd3699f3"
    let kCallbackURL = "pancakeapp://callback"
    // Using my own service in heroku | https://pancake-spotify-token-swap.herokuapp.com
    let kTokenSwapUrl = "https://pancake-spotify-token-swap.herokuapp.com/swap"
    let kTokenRefreshServiceUrl = "https://pancake-spotify-token-swap.herokuapp.com/refresh"
    let auth = SPTAuth.defaultInstance()

    // Login with Spotify button
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet var loginViewCrontoller: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register to be notified when the user has logged in successfully in order to dismiss the login view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.dismiss), name: "loginSuccessful", object: nil)

        // If session data is available, dismiss the loginViewController
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {// Session available
            // Used for debugging purposes only
            // print session
            //print(sessionObj)
        }
        
    }
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        auth.clientID = kClientID
        auth.requestedScopes = [SPTAuthStreamingScope]
        auth.redirectURL = NSURL(string:kCallbackURL)
        auth.tokenSwapURL = NSURL(string:kTokenSwapUrl)
        auth.tokenRefreshURL = NSURL(string:kTokenRefreshServiceUrl)
        
        let spotifyAuthenticationViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthenticationViewController.delegate = self
        
        spotifyAuthenticationViewController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        spotifyAuthenticationViewController.definesPresentationContext = true
        
        presentViewController(spotifyAuthenticationViewController, animated: false, completion: nil)
    }
    
    // MARK: - PTAuthViewDelegate Protocol
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        
        // Save new sessin data
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
        
        userDefaults.setObject(sessionData, forKey: "SpotifySession")
        userDefaults.synchronize()
        
        print("Login was successful");
        
        // Spotifiy session data has been received
        // Post notification to tell LoginViewController to be dismissed
        NSNotificationCenter.defaultCenter().postNotificationName("loginSuccessful", object: nil)
        
    }
    
    // Login failed with error
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("Login failed... \(error)")
        
    }
    
    // User cancel log in
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("Did Cancel Login...")
    }
    
    // When login is succesfull go to Dashboard
    func dismiss() {
        
        // Go to Dashboard
        print("Should dismiss loginViewController");
        self.navigationController?.popViewControllerAnimated(true);
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
