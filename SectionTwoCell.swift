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
    
    var nameLable = UILabel()
    var subtitleLable = UILabel()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLable = UILabel(frame: CGRect(x: 0, y: 5, width: 350, height: 20))
        subtitleLable = UILabel(frame: CGRect(x: 0, y: 35, width: 350, height: 15))
        
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        subtitleLable.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLable)
        contentView.addSubview(subtitleLable)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
