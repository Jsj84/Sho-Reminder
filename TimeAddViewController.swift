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
    let defaults = UserDefaults()
    var editID = Int()
    
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
            let dateAsString = dateFormatter.string(from: dateOnPicker)
            var tempInterval = String()
            var id = Int()
            if defaults.value(forKey: "id") == nil {
                id = 0
            }
            else {
                id = defaults.value(forKey: "id") as! Int
            }
            print(id)
            let NsId = id as NSNumber
            let identifier = NsId.stringValue
            
            if defaults.value(forKey: "repeat") == nil {
                tempInterval = "Never"
            }
            else {
                tempInterval = defaults.value(forKey: "repeat") as! String
            }
            
            // create push notifications
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.intervalNotification(date: dateOnPicker, title: "It's Time!", body: reminderDiscription.text!, identifier: identifier, theInterval: tempInterval)
            
            // save as NSObject
            fh.save(name: reminderDiscription.text!, dateString: dateAsString, date: dateOnPicker, repeatOption: tempInterval, id: id)
            
            let changedValue = id + 1
            defaults.setValue(changedValue, forKeyPath: "id")
            
            // clear text field
            reminderDiscription.text?.removeAll()
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addBackground()
        
        CancelBFef.backgroundColor = color
        CancelBFef.layer.cornerRadius = 8
        SaveBRef.backgroundColor = color
        SaveBRef.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = color
        
        timePicker.backgroundColor = UIColor.clear
        timePicker.setValue(UIColor.black, forKeyPath: "textColor")
    }
    override func viewWillAppear(_ animated: Bool) {
        fh.getData()
        if defaults.value(forKey: "cellId") != nil {
            let g = defaults.value(forKey: "cellId") as! Int
            print(g)
            let newDate = fh.timeObject[g].value(forKey: "date") as! Date
            let uploadText = fh.timeObject[g].value(forKey: "name") as! String
            reminderDiscription.text = uploadText
            reminderDiscription.reloadInputViews()
            timePicker.setDate(newDate, animated: true)
            timePicker.reloadInputViews()
        }
        tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        defaults.removeObject(forKey: "repeat")
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if defaults.value(forKey: "repeat") != nil {
            let timeRepeat = defaults.value(forKey: "repeat") as! String
            cell.textLabel?.text = "Repeat: " + "\(timeRepeat)"
        }
        else {
            cell.textLabel?.text = "Repeat: Never"
        }
        tableView.deselectRow(at: [indexPath.row], animated: true)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "intervalSegue", sender: AnyObject.self)
        
    }
}
