//
//  CreateNewViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 12/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit
import MobileCoreServices

class CreateNewViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    // Check if view is loaded from Home Screen or Alarms Table View
    var firstOpened = true
    
    // Changes color time depending on status
    var timeWhiteColorON = false
    
    // Reference to the background image
    var backgroundImage = UIImage()
    
    // UIImageView that displays the background image
    let backgroundView = UIImageView(frame: UIScreen.mainScreen().bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Changes the foreground color of the placeholder text
        alarmNameTextField.attributedPlaceholder = NSAttributedString(string: "Add alarm title", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0x707070)])
        
        // Setups backgroundView
        backgroundView.contentMode = .ScaleAspectFill
        // Removes portion of the image that is drawn but not visible untile segue.
        backgroundView.clipsToBounds = true
        // Makes backgrounView darker
        backgroundView.alpha = 0.5

        // Adds Background to view
        self.view.insertSubview(backgroundView, atIndex: 0)
        
    }

    override func viewWillAppear(animated: Bool) {
        // Updates Time Label
        self.updateTimeLabel()
        // Adds Selected image as background
        self.addBackgroundImage()
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
    
    func addBackgroundImage() {
        if (firstOpened == true) {
            print("No background image selected.")
        } else {
            backgroundView.image = backgroundImage
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
            self.photoWithCamera()
        }
        let libraryAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.Default) {(action) in
            print("Choose from library!")
            
            self.performSegueWithIdentifier("PhotoLibrarySegue", sender: self)

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
    
    // Opens Camera and takes photo
    func photoWithCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            // Displays alert when there is no camera found
            let authErrorAlert = JSSAlertView()
            
            // Alert setup
            authErrorAlert.show(self, title: "Oops...", text: "No camera detected", buttonText: "OK", color: UIColorFromHex(0xe74c3c, alpha: 1))
            authErrorAlert.setTextTheme(.Light)

        }
    }
    
    // Highlights/Unhighlights selected button
    func highlightButton(bttn: UIButton) {
        
        // Highlights/Unhighlights button depending on state.
        if bttn.titleColorForState(UIControlState.Normal) == UIColor.whiteColor() {
            let pancakeGrayColor = UIColorFromHex(0x707070)
            bttn.setTitleColor(pancakeGrayColor, forState: UIControlState.Normal)
            bttn.layer.borderColor = pancakeGrayColor.CGColor
        } else {
            bttn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            bttn.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }

    
    // Goes back to the ViewController that presented it
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Selects days of the week that alarm will be active
    @IBAction func selectDate(sender: AnyObject) {
        // Date Button
        let button = sender as! UIButton
        
        // Custom button highlight
        self.highlightButton(button)
        
        // Used for debugging purposes only
        //print("Date selected: \((button.titleLabel?.text)!)")
    }
    
    // MARK: - ImagePickerController Delegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // Sets background image
        backgroundImage = image
        backgroundView.image = image
        
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        self.addBackgroundImage()
        self.dismissViewControllerAnimated(true, completion: nil)
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
            
            photoLibraryViewController.firstViewController = self
            
        } else if (segue.identifier == "HomeScreenSegue" || segue.identifier == "TableViewSegue") {
            firstOpened = true
        }
    }


}
