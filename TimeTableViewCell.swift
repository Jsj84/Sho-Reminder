//
//  TimeTableViewCell.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/26/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

protocol SwitchChangedDelegate {
    func changeStateTo(isOn: Bool, row: Int)
}

class TimeTableViewCell: UITableViewCell {
    
    var userDefaults = UserDefaults.standard
    var delegate: SwitchChangedDelegate?
    var row: Int?
    
    @IBOutlet weak var myLabel_1: UILabel!
    @IBOutlet weak var myLabel_2: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    @IBAction func switchedState(_ sender: UISwitch) {
        self.delegate?.changeStateTo(isOn: sender.isOn, row: row!)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellSwitch.isOn = userDefaults.bool(forKey: "\(row)")
    }
    
}
