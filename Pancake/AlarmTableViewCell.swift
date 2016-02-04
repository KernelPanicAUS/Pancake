//
//  AlarmTableViewCell.swift
//  Pancake
//
//  Created by Angel Vazquez on 2/1/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var alarmTitle: UILabel!
    @IBOutlet weak var alarmDate: UILabel!
    @IBOutlet weak var alarmTime: UILabel!
    @IBOutlet weak var meri: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
