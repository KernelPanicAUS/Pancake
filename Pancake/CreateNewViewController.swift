//
//  CreateNewViewController.swift
//  Pancake
//
//
//   Modified by Angel Vázquez
//
//  Created by Rudy Rosciglione on 12/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class CreateNewViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Labels that display the selected Alarm Time
    @IBOutlet weak var timeLabel: UIButton!
    @IBOutlet weak var meridiemDisplay: UILabel!
    
    // Outlet for the textfield
    @IBOutlet weak var alarmNameTextField: UITextField!
    
    @IBOutlet weak var mon: DesignableButton!
    // Hold the correct alarm time
    var updatedTime = "Time"
    var updatedMeridiem = "meri"
    
    // Used to set off alarm
    var hoursForAlarm = 0
    var minutesForAlarm = 0
    
    // Hides am/pm when no alarm time is selected
    var hideMeridiem = true
    
    // Check if view is loaded from Home Screen or Alarms Table View
    var firstOpened = true
    
    // Changes color of time depending on status
    var timeWhiteColorON = false
    
    // Reference to the background image
    var backgroundImage = UIImage()
    
    // UIImageView that displays the background image
    let backgroundView = UIImageView(frame: UIScreen.mainScreen().bounds)
    
    var selectedDates = [String]()

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
        
        // Make corner button round
        for i in 2000...2006{
            let dateButton = self.view.viewWithTag(i) as! UIButton
            dateButton.layer.cornerRadius = dateButton.layer.bounds.size.height/1.7
        }
        
        
    }

    override func viewWillAppear(animated: Bool) {
        // Updates Time Label
        self.updateTimeLabel()
        // Adds Selected image as background
        self.addBackgroundImage()
        print("Hours: \(hoursForAlarm) + Minutes: \(minutesForAlarm)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Displays selected alarm time
    func updateTimeLabel() {
        timeLabel.setTitle(updatedTime, forState: UIControlState.Normal)
        meridiemDisplay.text = updatedMeridiem
        
        // Determines wether or not to hide AM/PM label
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
    
    // Makes sure there is no error when opening View / No background selected
    func addBackgroundImage() {
        if (firstOpened == true) {
            print("No background image selected.")
        } else {
            backgroundView.image = backgroundImage
        }
    }
    
    // Adds background photo - Take a picture or select from Library
    @IBAction func addPhoto(sender: AnyObject) {
        // Selection options for adding photo
        let photoSelectionOptionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Changes the background color of the AlertView to white
        photoSelectionOptionsAlertController.view.backgroundColor = UIColor.whiteColor()
        // Changes the color of the text to gray
        photoSelectionOptionsAlertController.view.tintColor = UIColor.lightGrayColor()
        
        // Lets user take picture
        let takePhotoAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.Default) {(action) in
            // Used for debugging purposes only
            //print("Take photo!")
            
            // Takes picture
            self.photoWithCamera()
        }
        // Lets user select picture from Library
        let libraryAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.Default) {(action) in
            // Used for debugging purposes only
            //print("Choose from library!")
            
            // Goes to photo selection view
            self.performSegueWithIdentifier("PhotoLibrarySegue", sender: self)
        }
        // Closes Alert (Photo selection method menu)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default){(action) in
            // Use for debugging purposes only
            //print("Cancel")
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
            authErrorAlert.show(self,
                title: "Oops...",
                text: "No camera detected",
                buttonText: "OK",
                color: UIColorFromHex(0xe74c3c, alpha: 1))
                authErrorAlert.setTextTheme(.Light)

        }
    }
    
    // Highlights or Unhighlights selected button
    func highlightButton(bttn: UIButton) {
        
        // Highlights or Unhighlights button depending on state.
        if bttn.titleColorForState(UIControlState.Normal) == UIColor.whiteColor() {
            let pancakeGrayColor = UIColorFromHex(0x707070)
            bttn.setTitleColor(pancakeGrayColor, forState: UIControlState.Normal)
            bttn.layer.borderColor = pancakeGrayColor.CGColor
            
            // Removes unselected dates from array
            for i in 0...selectedDates.count-1{
                if ((bttn.titleLabel?.text)! == selectedDates[i]) {
                     print("Hola")
                    self.selectedDates.removeAtIndex(i)
                }
               
            }
            
        } else {
            bttn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            bttn.layer.borderColor = UIColor.whiteColor().CGColor
            // Adds selected date to array
            selectedDates.append((bttn.titleLabel?.text)!)
            print("date: \((bttn.titleLabel?.text)!)")
            print("\(selectedDates)")
            
        }
    }

    
    // Goes back to the ViewController that presented it
    @IBAction func cancel(sender: AnyObject) {
        self.goBackToDashboard()
    }
    
    // Saves alarm
    @IBAction func success(sender: AnyObject) {
        // Alarm setup
//        let title = alarmNameTextField.text
//        let time = timeLabel.titleLabel?.text
//        let days = Alarm.sortDaysOfTheWeek(selectedDates)
//        let meri = meridiemDisplay.text
        
        if self.validateAlarm() {
            self.performSegueWithIdentifier("ShowPlaylists", sender: self)
        }
//        // Checks if alarm info is valid
//        if self.validateAlarm() {
//            // Saves new alarm
//            self.saveAlarm(title!, time: time!, days: days, meri: meri!)
//            
//            for i in 0 ..< selectedDates.count {
//                self.scheduleNotification(dayOfTheWeek(selectedDates[i]), hour: self.hoursForAlarm, minute: self.minutesForAlarm)
//            }
//            
//
//        }
        //self.performSegueWithIdentifier("ShowPlaylists", sender: self)
    }
    
    // Manages Alarm save to CoreData
//    func saveAlarm(title: String, time: String, days: String, meri: String) {
//        
//        // Application Delegate
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        // Manages CoreData
//        let managedContext = appDelegate.managedObjectContext
//        // Entity described in data model
//        let entity = NSEntityDescription.entityForName("Alarm", inManagedObjectContext: managedContext)
//        
//        // New Alarm
//        let alarm = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
//        
//        // Setups Alarm properties
//        alarm.setValue(title, forKey: "title")
//        alarm.setValue(time, forKey: "time")
//        alarm.setValue(meri, forKey: "meri")
//        alarm.setValue(days, forKey: "days")
//        
//        // Saves alarm if there are no errors
//        do {
//            try managedContext.save()
//            // Used for debugging purposes only
//            //print("Success saving date.")
//            let savedAlarmAlert = JSSAlertView()
//            savedAlarmAlert.show(self,
//                title: "Success!",
//                text: "Your alarm was saved succesfully\n",
//                buttonText: "OK",
//                color: UIColor.whiteColor())
//            
//            // Goes back to Dashboard when OK is pressed
//            savedAlarmAlert.addAction(goBackToDashboard)
//        } catch let error as NSError {
//            // Displays error message in console
//            print("Could not save \(error), \(error.userInfo)")
//        }
//    }
    
    // Checks if user enter all info needed to save alarm 
    func validateAlarm() -> Bool{
        if ((updatedTime == "Time") || (alarmNameTextField.text == nil)){
            let incompleteInfoAlert = JSSAlertView()
            incompleteInfoAlert.show(self,
                title: "Oops...",
                text: "You are missing important alarm information",
                buttonText: "OK",
                color: UIColor.whiteColor())
            return false
        }
        return true
    }
    
    // Selects days of the week that alarm will be active
    @IBAction func selectDate(sender: AnyObject) {
        // Date Button
        let button = sender as! UIButton
        
        // Custom button highlight
        self.highlightButton(button)
    }

    // MARK: - ImagePickerController Delegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Manages image taken with camera
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // Sets background image
        backgroundImage = image
        backgroundView.image = image
        
        // Saves image to library
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        // Adds taken image to background
        self.addBackgroundImage()
        
        // Makes current view dissapear
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Alarm setup
    
    // Manages notifications
    func scheduleNotification(dayOfWeek: Int, hour: Int, minute: Int) {
        print("Schedule Notification")
        
        // Fires alarm every Sunday at selected hour
        let gregCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let dateComponent = gregCalendar?.components([NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Weekday], fromDate: NSDate())
        
        // Set week day for recurring alarm
        dateComponent?.weekday = dayOfWeek
        dateComponent?.hour = hour
        dateComponent?.minute = minute
        
        let dd = UIDatePicker()
        dd.setDate((gregCalendar?.dateFromComponents(dateComponent!))!, animated: true)
        
        // Sends Alarm notification - You need to wake up now
        let alarmNotification = UILocalNotification()
        alarmNotification.fireDate = dd.date
        alarmNotification.alertBody = alarmNameTextField.text
        alarmNotification.alertAction = "OK"
        alarmNotification.userInfo = ["CustomField": "Woot"]
        UIApplication.sharedApplication().scheduleLocalNotification(alarmNotification)
        
        
    }
    
    // Returns date of the week
    func dayOfTheWeek(nameOfDay: String) -> Int {
        
        var dayOfTheWeekInt = 0
        
        switch nameOfDay {
            case "SUN":
                dayOfTheWeekInt = 1
            case "MON":
                dayOfTheWeekInt = 2
            case "TUE":
                dayOfTheWeekInt = 3
            case "WED":
                dayOfTheWeekInt = 4
            case "THU":
                dayOfTheWeekInt = 5
            case "FRI":
                dayOfTheWeekInt = 6
            case "SAT":
                dayOfTheWeekInt = 7
            default:
                print("Default")
        }
        
        
        return Int(dayOfTheWeekInt)
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
        } else if (segue.identifier == "ShowPlaylists") {
            let spotifyPlaylistCollectionViewController = segue.destinationViewController as! SpotifyPlaylistCollectionViewController
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            // Session available
            let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession")!
            
            let sessionObjData = sessionObj as! NSData
            
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionObjData) as! SPTSession
            
            spotifyPlaylistCollectionViewController.currentSession = session
            
            spotifyPlaylistCollectionViewController.alarmTitle = self.alarmNameTextField.text!
            spotifyPlaylistCollectionViewController.alarmTime = (self.timeLabel.titleLabel?.text)!
            spotifyPlaylistCollectionViewController.alarmDays = Alarm.sortDaysOfTheWeek(selectedDates)
            spotifyPlaylistCollectionViewController.alarmMeri = self.meridiemDisplay.text!
            spotifyPlaylistCollectionViewController.selectedDates = self.selectedDates
            spotifyPlaylistCollectionViewController.hoursForAlarm = self.hoursForAlarm
            spotifyPlaylistCollectionViewController.minutesForAlarm = self.minutesForAlarm
        }
    }

    // Goes to Main Screen - Dashboard
    func goBackToDashboard() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
