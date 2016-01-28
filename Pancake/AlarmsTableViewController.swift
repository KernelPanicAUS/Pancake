//
//  AlarmsTableViewController.swift
//  Pancake
//
//  Created by Rudy Rosciglione on 12/01/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit


class AlarmsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{

    // Outlet for Alarm Table View
    @IBOutlet weak var alarmsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // EmptyDataSet in our Alarm Table View
        self.alarmsTableView.emptyDataSetSource = self
        self.alarmsTableView.emptyDataSetDelegate = self
        
        // Clears Table View of divisor lines
        self.alarmsTableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Goes back to the ViewController that presented it
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - DZNEmptyDataSet
    
    // Displays image when there is an Empty Data Set
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        // Pancake is sad because there are no alarms setup :(
        return UIImage(named: "sadFace")
    }
    
    // Title and Description are having trouble being displayed.. Needs some love. :)
    /*
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "Huh"
        
        let attrs = [NSFontAttributeName: UIFont.systemFontOfSize(28.0)]
        
        return NSAttributedString(string: title, attributes: attrs)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        // Message to be displayed when Table View is empty
        let description = "You have no alarms setup yet..."
        
        let paragraph = NSMutableParagraphStyle()
        
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        
        let attrs = [NSFontAttributeName: UIFont.systemFontOfSize(18.0),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: description, attributes: attrs)
        
        
    }
    */
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ALARM_CELL", forIndexPath: indexPath)
        //cell.textLabel?.text = "Alarm 1"
        return cell
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
