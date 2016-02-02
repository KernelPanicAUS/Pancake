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
    
    var alarms = [Alarm]()
    
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
    
    // Empty Data Set Title
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        // Title message to be displayed when Table View is empty
        let title = "Huh!"
        
        // Custom font
        let proximaNovaBold = UIFont(name: "ProximaNova-Bold", size: 24.0)
        
        // Manages attributes for displayed text
        let attrs: [String : AnyObject] = [NSFontAttributeName: proximaNovaBold!,
                NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        return NSAttributedString(string: title, attributes: attrs)
    }
    
    // Empty Data Set Description
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        // Message to be displayed when Table View is empty
        let description = "You have no alarms setup yet"

        // Custom font
        let proximaNovaRegular = UIFont(name: "ProximaNova-Regular", size: 18.0)
        
        // Manages attributes for displayed text
        let attrs: [String : AnyObject] = [NSFontAttributeName: proximaNovaRegular!,
            NSForegroundColorAttributeName: UIColorFromHex(0x707070)]
        
        return NSAttributedString(string: description, attributes: attrs)
    }
    
    // Empty Data Set Image
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        // Pancake is sad because there are no alarms setup :(
        return UIImage(named: "sadFace")
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
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: AlarmTableViewCell = tableView.dequeueReusableCellWithIdentifier("ALARM_CELL") as! AlarmTableViewCell
        
        cell.alarmTitle.text = alarms[indexPath.row].title
        cell.alarmTime.text = alarms[indexPath.row].time
        cell.meri.text = alarms[indexPath.row].meri
        cell.alarmDate.text = alarms[indexPath.row].days
        
       /*
        cell.alarmTitle.text = "Slowly together"
        cell.alarmTime.text = "05:30"
        cell.meri.text = "am"
        cell.alarmDate.text = "Fri, Sat"*/
        //cell.textLabel?.text = "Alarm 1"
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
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
