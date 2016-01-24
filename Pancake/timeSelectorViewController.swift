//
//  timeSelectorViewController.swift
//  Pancake
//
//  Created by Angel Vazquez on 1/24/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class timeSelectorViewController: UIViewController{

    @IBOutlet weak var timePicker: UIDatePicker!
    
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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
