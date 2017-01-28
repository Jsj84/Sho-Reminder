//
//  TimeZoneViewController.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/27/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

class TimeZoneViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var color = UIColor(netHex:0x90F7A3)
    let timeZones = ["Estern", "Western"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = color
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeZones.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = timeZones[indexPath.row]
        return cell!
    }
}
