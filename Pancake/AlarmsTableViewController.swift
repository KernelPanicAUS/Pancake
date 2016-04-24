//
//  AlarmsTableViewController.swift
//  Pancake
//
//  Modified by Angel Vázquez
//
//  Created by Rudy Rosciglione on 12/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit
import CoreData

class AlarmsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{

    // Outlet for Alarm Table View
    @IBOutlet weak var alarmsTableView: UITableView!
    
    // Contains all of saved alarms
    var alarms = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // EmptyDataSet in our Alarm Table View
        self.alarmsTableView.emptyDataSetSource = self
        self.alarmsTableView.emptyDataSetDelegate = self
        
        // Clears Table View of divisor lines
        self.alarmsTableView.tableFooterView = UIView()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Loads custom cell
        let nib = UINib(nibName: "AlarmTableViewCell", bundle: nil)
        alarmsTableView.registerNib(nib, forCellReuseIdentifier: "ALARM_CELL")
        
        // Fetches saved alarms from CoreData
        self.fetchData()
        
    }

    override func viewWillAppear(animated: Bool) {
        // Reloads TableView every time view is going to appear
        alarmsTableView.reloadData()
        print("Hi")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Gets Alarms Stored in CoreData
    func fetchData() {
        // Application Delegate
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        // Manages CoreData
        let context:NSManagedObjectContext = appDel.managedObjectContext
        
        // Feteches saved alarms
        let fetchRequest = NSFetchRequest(entityName: "Alarm")
        do {
            try alarms = context.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not load data error: \(error), \(error.userInfo)")
        }
    }
    
    // Goes back to the ViewController that presented it
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - DZNEmptyDataSet
    
    // Empty Data Set Title
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        // Title message to be displayed when Table View is empty
        let title = "Huh!"
        
        // Custom font
        let proximaNovaBold = UIFont.systemFontOfSize(38, weight: UIFontWeightHeavy)//UIFont(name: "ProximaNova-Bold", size: 24.0)
        
        // Manages attributes for displayed text
        let attrs: [String : AnyObject] = [NSFontAttributeName: proximaNovaBold,
                NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        return NSAttributedString(string: title, attributes: attrs)
    }
    
    // Empty Data Set Description
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        // Message to be displayed when Table View is empty
        let description = "You have no alarms setup yet"

        // Custom font
        let proximaNovaRegular = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        
        // Manages attributes for displayed text
        let attrs: [String : AnyObject] = [NSFontAttributeName: proximaNovaRegular,
            NSForegroundColorAttributeName: UIColorFromHex(0x707070)]
        
        return NSAttributedString(string: description, attributes: attrs)
    }
    
    // Empty Data Set Image
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        // Pancake is sad because there are no alarms setup :(
        return UIImage(named: "sadFace")
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -30
    }
    
    func spaceHeightForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return 5.0
    }
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if (alarms.count ==  0) {
            return 0
        }
        
        return alarms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: AlarmTableViewCell = tableView.dequeueReusableCellWithIdentifier("ALARM_CELL") as! AlarmTableViewCell
        
        let alarm = alarms[indexPath.row]
        
        cell.alarmTitle.text = alarm.valueForKey("title") as? String
        cell.alarmTime.text = alarm.valueForKey("time") as? String
        cell.meri.text = alarm.valueForKey("meri") as? String
        cell.alarmDate.text = alarm.valueForKey("days") as? String

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // Manages item to be deleted
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDelegate.managedObjectContext
            
            // Deletes selected item from CoreData
            context.deleteObject(alarms[indexPath.row])
            
            // Removes item from alarms array
            alarms.removeAtIndex(indexPath.row)
            
            // Saves current CoreData context
            do {
                try context.save()
            } catch {
                // Needs better error handling.
                print("Error saving.")
            }
            
            // Deletes item from TableView (Visually)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        }
        self.alarmsTableView.reloadEmptyDataSet()
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        

    }
    */

}
