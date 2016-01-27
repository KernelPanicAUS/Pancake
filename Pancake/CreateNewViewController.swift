//
//  CreateNewViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 12/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class CreateNewViewController: UIViewController, UITextFieldDelegate {

    // Labels that display the selected Alarm Time
    @IBOutlet weak var timeLabel: UIButton!
    @IBOutlet weak var meridiemDisplay: UILabel!
    
    // Outlet for the textfield
    @IBOutlet weak var alarmNameTextField: UITextField!
   
    // Hold the correct alarm time
    var updatedTime = "Time"
    var updatedMeridiem = "meri"
    
    // Hides am/pm when no alarm time is selected
    var hideMeridiem = true
    
    // Changes color time depending on status
    var timeWhiteColorON = false
    
    // Reference to the background image
    var backgroundImage = "setupBGFrance"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Changes the foreground color of the placeholder text
        alarmNameTextField.attributedPlaceholder = NSAttributedString(string: "Add alarm title", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0x707070)])
        
        
    }

    override func viewWillAppear(animated: Bool) {
        self.updateTimeLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Displays selected alarm time
    func updateTimeLabel() {
        timeLabel.setTitle(updatedTime, forState: UIControlState.Normal)
        meridiemDisplay.text = updatedMeridiem
        
        if hideMeridiem == true{
            // Hide
            meridiemDisplay.hidden = true
        } else {
            // Show
            meridiemDisplay.hidden = false
            
            // If user selects Alarm Time - Make the label white
            timeLabel.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            meridiemDisplay.textColor = UIColor.whiteColor()
        }
    }
    
    @IBAction func addPhoto(sender: AnyObject) {
        // Selection options for adding photo
        let photoSelectionOptionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // UIImageView that displays the background image
        let backgroundView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundView.contentMode = .ScaleAspectFill
        // Removes portion of the image that is drawn but not visible untile segue.
        backgroundView.clipsToBounds = true
        
        // Changes the background color of the AlertView to white
        photoSelectionOptionsAlertController.view.backgroundColor = UIColor.whiteColor()
        // Changes the color of the text to gray
        photoSelectionOptionsAlertController.view.tintColor = UIColor.lightGrayColor()
        
        let takePhotoAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.Default) {(action) in
            print("Take photo!")
        }
        let libraryAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.Default) {(action) in
            print("Choose from library!")
            backgroundView.image = UIImage(named: self.backgroundImage)
            // Adds Background to view
            self.view.insertSubview(backgroundView, atIndex: 0)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default){(action) in
            print("Cancel")
        }
        
        
        
        // Adds actions to the photoSelectionOptionsAlertController
        photoSelectionOptionsAlertController.addAction(takePhotoAction)
        photoSelectionOptionsAlertController.addAction(libraryAction)
        photoSelectionOptionsAlertController.addAction(cancelAction)
        
        // Displays options on screen
        presentViewController(photoSelectionOptionsAlertController, animated: true, completion: nil)
    }
    // Goes back to the ViewController that presented it
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - TextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // If user pressed done - Dismiss Keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Checks which segue is going to happen
        if segue.identifier == "AddTime"{
            
            let timeSelectorViewController = segue.destinationViewController as! TimeSelectorViewController

            timeSelectorViewController.firstViewController = self
            
            // Sends current background image to Time Selector view
            timeSelectorViewController.backgroundImage = self.backgroundImage
        } else if (segue.identifier == "PhotoLibrarySegue") {
            let photoLibraryViewController = segue.destinationViewController as! PhotoLibraryViewController
            
            //photoLibraryViewController.firstViewController = self
        }
}


}
