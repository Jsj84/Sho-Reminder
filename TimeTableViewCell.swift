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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
