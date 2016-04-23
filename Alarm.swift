//
//  Alarm.swift
//  Pancake
//
//  Created by Angel Vazquez on 2/1/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class Alarm {
    // MARK: Properties
    var title: String
    var time: String
    var days: String
    //var days: NSMutableArray
    var meri: String
    
    init(title: String, time: String, days: String, meri: String){
        // Initialize stored properties
        self.title = title
        self.time = time
        self.days = days
        self.meri = meri
        
        // If no Alarm name
        if title.isEmpty {
            self.time = "Alarm"
        }
    }
    
    static func sortDaysOfTheWeek(days: [String]) -> String{
        
        var dateString = ""
        
//        var mon = 0
//        var tue = 0
//        var wed = 0
//        var thu = 0
//        var fri = 0
//        var sat = 0
//        var sun = 0
//        
//        var daysOfTheWeek = ["Mon":1,
//                             "Tue":2,
//                             "Wed":3,
//                             "Thu":4,
//                             "Fri":5,
//                             "Sat":6,
//                             "Sun":7]
//        
        print(days)
        for i in 0..<days.count {
            
            if days[i] == "MON"{
                dateString.appendContentsOf("Mon")
            } else if (days[i] == "TUE") {
                dateString.appendContentsOf("Tue")
            } else if (days[i] == "WED") {
                dateString.appendContentsOf("Wed")
            } else if (days[i] == "THU") {
               dateString.appendContentsOf("Thu")
            } else if (days[i] == "FRI") {
                dateString.appendContentsOf("Fri")
            } else if (days[i] == "SAT") {
                dateString.appendContentsOf("Sat")
            } else {
                dateString.appendContentsOf("Sun")
            }
            
            
        }
        
        
        
        
        return dateString
    }
}
