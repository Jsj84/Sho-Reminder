//
//  PopUpViewCell.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/9/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

class PopUpViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    public func configure(text: String?, placeholder: String) {
        textField.text = text
        textField.placeholder = placeholder
        
        textField.accessibilityValue = text
        textField.accessibilityLabel = placeholder
    }
}
