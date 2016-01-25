//
//  timeSelectorViewController.swift
//  Pancake
//
//  Created by Angel Vazquez on 1/24/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class TimeSelectorViewController: UIViewController{

    @IBOutlet weak var timePicker: UIDatePicker!
    weak var firstViewController = CreateNewViewController()
    
    override func viewDidLoad() {
        
        // Changes color of Time Picker to white
        timePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        
    }
    
    // Returns to Main Screen
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Returns to Alarm Setup
    @IBAction func success(sender: AnyObject) {
        
        let time = NSDateFormatter.localizedStringFromDate(timePicker.date, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
       
        // Creates a custom Time format
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        
        // Displays time in custom format "hh:mm"
        let now = timePicker.date
        let formattedTime = timeFormatter.stringFromDate(now)
        
        // Checks if Time is AM or PM
        if ((time.rangeOfString("AM")) != nil) {
            // It's the morning. Give some love :)
            firstViewController!.updatedMeridiem = "am"
        } else if ((time.rangeOfString("PM")) != nil){
            // It's already evening
            firstViewController!.updatedMeridiem = "pm"
        } else {
            print("Error. No time section found.")
        }

        // Makes am/pm visible
        firstViewController!.hideMeridiem = false
        
        // Show updated time in Alarm Setup
        firstViewController!.updatedTime = formattedTime
        
        // Used for debugging purposes only
        //print("Alarm Time: \(time)")
        
        // Takes us back to Alarm Setup
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
