//
//  TimeViewController.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/25/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class TimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var fh = ManagedObject()
    var userDefaults = UserDefaults.standard
    var color = UIColor(netHex:0x90F7A3)
    let tc = TimeTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fh.getData()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
        tableView.separatorColor = color
    
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
        
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saved Reminders"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fh.names.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = fh.names[indexPath.row] as? String
        cell.myLabel_2.text = fh.dateString[indexPath.row]
        for _ in [indexPath.row] {
          cell.mySwitch.isOn = self.userDefaults.bool(forKey: "\(tc.i)")
            tc.i = tc.i + 1
            print(tc.i)
        }
        cell.backgroundColor = UIColor.white
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let nameToDelete = indexPath.row
            let dateToDelete = indexPath.row
            fh.deleteRecords(name: nameToDelete, date: dateToDelete)
            fh.names.remove(at: indexPath.row)
            fh.date.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
