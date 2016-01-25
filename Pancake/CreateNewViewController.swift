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
    
    @IBOutlet weak var alarmNameTextField: UITextField!
    // Hold the correct alarm time
    var updatedTime = "Time"
    var updatedMeridiem = "meri"
    
    // Hides am/pm when no alarm time is selected
    var hideMeridiem = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmNameTextField.delegate = self

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
        
        if hideMeridiem == true {
            meridiemDisplay.hidden = true
        } else {
            meridiemDisplay.hidden = false
        }
    }
    
    @IBAction func addPhoto(sender: AnyObject) {
        // Selection options for adding photo
        let photoSelectionOptionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Changes the background color of the AlertView to white
        photoSelectionOptionsAlertController.view.backgroundColor = UIColor.whiteColor()
        // Changes the color of the text to gray
        photoSelectionOptionsAlertController.view.tintColor = UIColor.lightGrayColor()
        
        let takePhotoAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.Default) {(action) in
            print("Take photo!")
        }
        let libraryAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.Default) {(action) in
            print("Choose from library!")
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
            var timeSelectorViewController = segue.destinationViewController as! TimeSelectorViewController

            timeSelectorViewController.firstViewController = self
        }
}


}
