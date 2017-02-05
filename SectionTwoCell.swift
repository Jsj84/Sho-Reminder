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
        
        nameLable = UILabel(frame: CGRect(x: 14, y: 3, width: 350, height: 37))
        subtitleLable = UILabel(frame: CGRect(x: 6, y: 43, width: 350, height: 14))
        
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        nameLable.numberOfLines = 3
        nameLable.adjustsFontSizeToFitWidth = true
        subtitleLable.font = UIFont.systemFont(ofSize: 14)
        subtitleLable.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLable.textColor = UIColor.lightGray
        
        contentView.addSubview(nameLable)
        contentView.addSubview(subtitleLable)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
