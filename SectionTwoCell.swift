//
//  SectionTwoCell.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/8/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

class SectionTwoCell: UITableViewCell {
    
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var subtitleLable: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var entranceOrExit: UILabel!
    
    var color = UIColor(netHex:0x90F7A3)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLable.adjustsFontSizeToFitWidth = true
        nameLable.numberOfLines = 4
        
        subtitleLable.font = UIFont (name: "EuphemiaUCAS-Italic", size: 13)!
        subtitleLable.textColor = UIColor.black
        subtitleLable.adjustsFontSizeToFitWidth = true

        entranceOrExit.font = UIFont (name: "EuphemiaUCAS-Italic", size: 13)!
        entranceOrExit.textColor = UIColor.black
        entranceOrExit.backgroundColor = color
        entranceOrExit.layer.masksToBounds = true
        entranceOrExit.layer.cornerRadius = 5
        entranceOrExit.heightAnchor.constraint(equalToConstant: 27).isActive = true
        entranceOrExit.textAlignment = .center

    }
}
