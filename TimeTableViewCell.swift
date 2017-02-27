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
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var myLabel_1: UILabel!
    @IBOutlet weak var myLabel_2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myLabel_1.adjustsFontSizeToFitWidth = true
        myLabel_2.adjustsFontSizeToFitWidth = true
        
        myLabel_1.font = UIFont(name: "HelveticaNeue-Bold", size: 14)!
        myLabel_2.font = UIFont(name: "HelveticaNeue-Bold", size: 14)!
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
}
