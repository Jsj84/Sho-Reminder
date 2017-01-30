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
    var defaults = UserDefaults()
    
    let timeZones = [
        "America/Halifax",
        "America/Juneau",
        "America/Juneau",
        "America/Argentina/Buenos_Aires",
        "America/Halifax",
        "Asia/Dhaka",
        "America/Sao_Paulo",
        "America/Sao_Paulo",
        "Europe/London",
        "Africa/Harare",
        "America/Chicago",
        "Europe/Paris",
        "Europe/Paris",
        "America/Santiago",
        "America/Santiago",
        "America/Bogota",
        "America/Chicago",
        "Africa/Addis_Ababa",
        "America/New_York",
        "GMT",
        "Europe/Istanbul",
        "Europe/Istanbul",
        "America/New_York",
        "Asia/Dubai",
        "Asia/Hong_Kong",
        "Pacific/Honolulu",
        "Asia/Bangkok",
        "Asia/Tehran",
        "Asia/Calcutta",
        "Asia/Tokyo",
        "Asia/Seoul",
        "America/Denver",
        "Europe/Moscow",
        "Europe/Moscow",
        "America/Denver",
        "Pacific/Auckland",
        "Pacific/Auckland",
        "America/Los_Angeles",
        "America/Lima",
        "Asia/Manila",
        "Asia/Karachi",
        "America/Los_Angeles",
        "Asia/Singapore",
        "UTC",
        "Africa/Lagos",
        "Europe/Lisbon",
        "Europe/Lisbon",
        "Asia/Jakarta"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = color
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose a timezone"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeZones.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = timeZones[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let chosenZone = tableView.cellForRow(at: indexPath)?.textLabel?.text
        defaults.set(chosenZone, forKey: "timeZone")
        self.dismiss(animated: true, completion: nil)
    }
}
