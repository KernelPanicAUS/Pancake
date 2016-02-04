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
}
