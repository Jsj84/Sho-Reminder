//
//  IntervalViewController.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/26/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit


class IntervalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaults = UserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = ["Hourly", "Daily", "Weekly", "Monthly", "Yearly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.view.backgroundColor = UIColor.groupTableViewBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = true
        tableView.separatorColor = UIColor.green
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return dataSource.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if indexPath.section == 0 {
            cell?.textLabel?.text = "Never"
        }
        else {
        cell?.textLabel?.text = dataSource[indexPath.row]
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let cellText = tableView.cellForRow(at: indexPath)?.textLabel?.text
        defaults.set(cellText!, forKey: "repeat")
        dismiss(animated: true, completion: nil)
    }
}
