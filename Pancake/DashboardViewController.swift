//
//  DashboardViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 05/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var imageTimeDisplay: UIImageView!

    @IBOutlet weak var userDailyMessage: UILabel!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var dateDisplay: UILabel!
    @IBOutlet weak var meridiemDisplay: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Spotify is checking if the user is login
        self.spotifyUserCheck()
        
        // Update Time Periodically
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timeUpdate", userInfo: nil, repeats: true)
        

        // Do any additional setup after loading the view.
    }

    
    // Updates Time and all its elements
    func timeUpdate(){
       // Displays Time.
        self.timeDisplay.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        // Displays Date.
        self.dateDisplay.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        // Checks if Time is AM or PM
        if ((timeDisplay.text?.rangeOfString("AM")) != nil) {
            // It's the morning. Give some love :)
            userDailyMessage.text = "Good Morning"
            meridiemDisplay.text = "AM"
        } else if ((timeDisplay.text?.rangeOfString("PM")) != nil){
            // It's already evening
            userDailyMessage.text = "Good Evening"
            meridiemDisplay.text = "PM"
        } else {
            print("Error. No time section found.")
        }
        
        // For debugging purposes onlye
        //print(timeDisplay.text)
        
        
    }
    
    func spotifyUserCheck() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {// Session available
            // print session
            print(sessionObj)
            print("Already Logged in ")
        } else {
            print("New User")
            self.performSegueWithIdentifier("newUser", sender: nil)
        }
        
    }
    // Function relative to Spotify checking
    
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
