//
//  LoginViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 18/12/15.
//  Copyright © 2015 Rudy Rosciglione. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let kClientID = "57fba5f8821f41cfa5bbae644ad46ce7"
    let kCallbackURL = "pancakeapp://returnAfterLogin"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"

    @IBOutlet weak var loginButton: DesignableButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAfterFirstLogin", name: "LoginSuccessFull", object: nil)

        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") { // Session Avaible
        
        }else{
            loginButton.hidden = false
        }

        
        // Do any additional setup after loading the view.
    }
    
    func updateAfterFirstLogin(){
        loginButton.hidden = true
    }

    @IBAction func loginWithSpotify(sender: AnyObject) {
        let auth = SPTAuth.defaultInstance()
        
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
