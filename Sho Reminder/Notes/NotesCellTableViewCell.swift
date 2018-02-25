//
//  NotesCellTableViewCell.swift
//  Sho Reminder
//
//  Created by Jesse on 1/8/18.
//  Copyright © 2018 JNJ Apps. All rights reserved.
//

import UIKit
import Foundation

class NotesCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateModified: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = UIFont (name: "EuphemiaUCAS-Bold", size: 14)!
        titleLabel.textColor = UIColor.black
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.numberOfLines = 1
        
        contentLabel.font = UIFont (name: "EuphemiaUCAS-Italic", size: 11)!
        contentLabel.textColor = UIColor.black
        contentLabel.adjustsFontSizeToFitWidth = false
        contentLabel.numberOfLines = 2
        
        dateModified.font = UIFont (name: "EuphemiaUCAS-Italic", size: 10)!
        dateModified.textColor = UIColor.black
        dateModified.adjustsFontSizeToFitWidth = true
        dateModified.numberOfLines = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
