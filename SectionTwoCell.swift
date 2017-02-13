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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLable.adjustsFontSizeToFitWidth = true
        nameLable.numberOfLines = 10
        nameLable.preferredMaxLayoutWidth = nameLable.bounds.width
        nameLable.font = UIFont (name: "HelveticaNeue-Bold", size: 14)!
        
        subtitleLable.font = UIFont (name: "HelveticaNeue-Bold", size: 14)!
        subtitleLable.textColor = UIColor.white
    }
    
}
