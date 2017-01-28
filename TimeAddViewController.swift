//
//  TimeAddViewController.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/3/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class TimeAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)
    let tableData = ["Repeat", "Time Zone"]
    var dateAsString = ""
    
    @IBOutlet weak var reminderDiscription: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CancelBFef: UIButton!
    @IBOutlet weak var SaveBRef: UIButton!
    
    @IBAction func cancelB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func SaveB(_ sender: Any) {
        if reminderDiscription.text?.isEmpty == true {
            let alert = UIAlertController(title: "Alert", message: "You cannot save this reminder without a description", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.view.endEditing(true)
            let dateFormatter = DateFormatter()
            let dateOnPicker = timePicker.date //capture the date shown on the picker
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateAsString = dateFormatter.string(from: dateOnPicker)
            
             // create push notifications
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.scheduleNotification(atDate: dateOnPicker, body: reminderDiscription.text!, title: "Reminder", identifier: reminderDiscription.text!)
            
            // save as NSObject
            fh.save(name: reminderDiscription.text!, dateString: dateAsString, date: dateOnPicker)
            
            // clear text field
            reminderDiscription.text?.removeAll()
            self.dismiss(animated: true, completion: nil)            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        CancelBFef.backgroundColor = color
        CancelBFef.layer.cornerRadius = 8
        SaveBRef.backgroundColor = color
        SaveBRef.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = color
        
        timePicker.backgroundColor = UIColor.clear
        
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = tableData[indexPath.row]
        cell.backgroundColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "intervalSegue", sender: AnyObject.self)
        }
        else {
            performSegue(withIdentifier: "timeZoneSegue", sender: AnyObject.self)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: [indexPath.row], animated: false)
    }
}
