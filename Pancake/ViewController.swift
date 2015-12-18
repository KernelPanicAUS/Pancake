//
//  ViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 09/12/15.
//  Copyright © 2015 Rudy Rosciglione. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    let kClientID = "e644c0618991483d831ad1e34d037f7b"
    let kCallbackURL = "pancake-app://callback/"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"


    @IBOutlet weak var loginButton: DesignableButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view, typically from a nib
    }


    @IBAction func loginWithSpotify(sender: AnyObject) {
        let auth = SPTAuth.defaultInstance()
        
        let loginURL = auth.loginURLForClientId(kClientID, declaredRedirectURL: NSURL(string: kCallbackURL), scopes: [SPTAuthStreamingScopes])
        
        UIApplication.sharedApplication().openURL(loginURL)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
}
