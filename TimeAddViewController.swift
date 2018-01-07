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
    let indexPath = Int()
    var tempText = ""
    var tempData = Date()
    var newBackButton = UIBarButtonItem()
    
    @IBOutlet weak var reminderDiscription: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SaveBRef: UIBarButtonItem!
    
    @IBAction func SaveB(_ sender: Any)  {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        var tempInterval = String()
        var id = Int()
        let now = Date()
        let olderDate = NSCalendar.current.compare(now as Date, to: timePicker.date, toGranularity: .minute)
        let dateFormatter = DateFormatter()
        let dateOnPicker = timePicker.date
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateAsString = dateFormatter.string(from: dateOnPicker)
        
        if reminderDiscription.text?.isEmpty == true {
            let alert = UIAlertController(title: "Alert", message: "You cannot save this reminder without a description", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if olderDate == .orderedDescending && defaults.value(forKey: "repeat") == nil {
            let alert = UIAlertController(title: "Alert", message: "Looks like the date you are trying to save has already passed. Choose a later date or add the option to repeat", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            self.view.endEditing(true)
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
            if defaults.bool(forKey: "bool") == true {
                
                let i = defaults.value(forKey: "cellId") as! Int
                let temp = fh.timeObject[i].value(forKey: "id") as! Int
                let tempIdentifier = temp as NSNumber
                let tempiString = tempIdentifier.stringValue
                
                fh.updateTimeData(name: reminderDiscription.text!, dateString: dateAsString, date: dateOnPicker, repeatOption: tempInterval, id: temp, index: i)
                
                delegate?.deleteNotification(identifier: tempiString)
                delegate?.intervalNotification(date: dateOnPicker, title: "It's Time!", body: reminderDiscription.text!, identifier: tempiString, theInterval: tempInterval)
                
            }
            if defaults.bool(forKey: "bool") == false {
                // create push notifications
                delegate?.intervalNotification(date: dateOnPicker, title: "It's Time!", body: reminderDiscription.text!, identifier: identifier, theInterval: tempInterval)
                
                // save as NSObject
                fh.save(name: reminderDiscription.text!, dateString: dateAsString, date: dateOnPicker, repeatOption: tempInterval, id: id)
                
                let changedValue = id + 1
                defaults.setValue(changedValue, forKeyPath: "id")
            }
            // clear text field
            reminderDiscription.text?.removeAll()
            let v = storyboard?.instantiateViewController(withIdentifier: "nav")
            self.present(v!, animated: true, completion: nil)
            
        }
    }
    @objc func back(sender: UIBarButtonItem) {
        defaults.set(false, forKey: "bool")
        defaults.removeObject(forKey: "repeat")
        self.tabBarController?.selectedIndex = 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fh.getData()
        self.navigationItem.hidesBackButton = true
        newBackButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        newBackButton.tintColor = UIColor.red
        newBackButton.isEnabled = false
        newBackButton.title = ""
        
        if (reminderDiscription.text?.isEmpty)!{
            SaveBRef.isEnabled = false
            SaveBRef.title = ""
        }
        reminderDiscription.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        self.view.backgroundColor = color
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.separatorColor = color
        
        timePicker.backgroundColor = UIColor.groupTableViewBackground
        timePicker.setValue(UIColor.black, forKeyPath: "textColor")
        
        reminderDiscription.keyboardAppearance = .dark
        
        self.hideKeyboardWhenTappedAround()
        
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if reminderDiscription.text?.isEmpty == false {
            SaveBRef.isEnabled = true
            SaveBRef.title = "Save"
            
            newBackButton.isEnabled = true
            newBackButton.title = "Cancel"
        }
        else {
            SaveBRef.isEnabled = false
            SaveBRef.title = ""
            newBackButton.isEnabled = false
            newBackButton.title = ""
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        fh.getData()
        if defaults.value(forKey: "cellId") != nil && defaults.bool(forKey: "bool") != false {
            SaveBRef.isEnabled = true
            SaveBRef.title = "Save"
           newBackButton.isEnabled = true
            newBackButton.title = "Cancel"
            let g = defaults.value(forKey: "cellId") as! Int
            let newDate = fh.timeObject[g].value(forKey: "date") as! Date
            let uploadText = fh.timeObject[g].value(forKey: "name") as! String
            reminderDiscription.text = uploadText
            reminderDiscription.reloadInputViews()
            timePicker.setDate(newDate, animated: true)
            timePicker.reloadInputViews()
            
        }
    
        else if defaults.value(forKey: "temp") != nil {
            reminderDiscription.text = tempText
            timePicker.date = tempData
       }
        else {
            timePicker.setDate(Date(), animated: true)
            reminderDiscription.text = nil
            SaveBRef.isEnabled = false
            newBackButton.isEnabled = false
            SaveBRef.title = ""
            newBackButton.title = ""
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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
        else if defaults.bool(forKey: "bool") == true {
            let g = defaults.value(forKey: "cellId") as! Int
            let option = fh.timeObject[g].value(forKey: "repeatOption") as! String
            cell.textLabel?.text = "Repeat: " + "\(option)"
        }
        else {
            cell.textLabel?.text = "Repeat: Never"
        }
        tableView.deselectRow(at: [indexPath.row], animated: true)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tempText = reminderDiscription.text!
        tempData = timePicker.date
        defaults.set(true, forKey: "temp")
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "Intervalviewcontroler") as! IntervalViewController
        self.present(myVC, animated: true, completion: nil)
        
    }
    
}
