//
//  TimeTableViewCell.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/26/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

class TimeTableViewCell: UITableViewCell {
    
    var userDefaults = UserDefaults()
    var i = 0
    
    @IBOutlet weak var myLabel_1: UILabel!
    @IBOutlet weak var myLabel_2: UILabel!
    @IBOutlet weak var mySwitch: UISwitch!
    
    @IBAction func switchedState(_ sender: Any) {
        if mySwitch.isOn == true {
            userDefaults.set(true, forKey: "\(i)")
            myLabel_1.textColor = UIColor.black
            myLabel_2.textColor = UIColor.black
        }
        else if mySwitch.isOn == false {
            userDefaults.set(false, forKey: "\(i)")
            myLabel_1.textColor = UIColor.lightGray
            myLabel_2.textColor = UIColor.lightGray
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
