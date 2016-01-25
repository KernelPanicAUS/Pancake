//
//  CreateNewViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 12/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class CreateNewViewController: UIViewController {

    @IBOutlet weak var timeLabel: UIButton!
    @IBOutlet weak var meridiemDisplay: UILabel!
    
    var updatedTime = "Time"
    var updatedMeridiem = "meri"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        self.updateTimeLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTimeLabel() {
        timeLabel.setTitle(updatedTime, forState: UIControlState.Normal)
        meridiemDisplay.text = updatedMeridiem
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddTime"{
            var timeSelectorViewController = segue.destinationViewController as! TimeSelectorViewController
            
            timeSelectorViewController.firstViewController = self
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
