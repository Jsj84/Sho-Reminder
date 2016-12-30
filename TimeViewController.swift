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

class TimeViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var reminderName: UILabel!
    @IBOutlet weak var reminderDiscription: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var fh = ManagedObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fh.getData()
        
        timePicker.backgroundColor = UIColor.black
        timePicker.layer.cornerRadius = 10
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        view.backgroundColor = UIColor.clear
        
        reminderDiscription.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.isOpaque = true
        tableView.allowsSelection = false
        reminderDiscription.returnKeyType = UIReturnKeyType.done
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if reminderDiscription.text?.isEmpty == true {
            let alert = UIAlertController(title: "Alert", message: "You cannot save this reminder without a description", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.view.endEditing(true)
            
            let dateOnPicker = timePicker.date //capture the date shown on the picker
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.scheduleNotification(atDate: dateOnPicker, body: reminderDiscription.text!)

            
            let dateFormatter = DateFormatter() //create a date formatter
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short
            let timeString = dateFormatter.string(from: dateOnPicker)
            
            fh.writeData(Items: "Items", name: textField.text!, date: timePicker.date)
            fh.names.append(textField.text! as NSObject)
            fh.date.append(timeString as NSObject)
            reminderDiscription.text?.removeAll()
            
            tableView.reloadData()
        }
        return false
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = fh.names[indexPath.row] as? String
        cell.myLabel_2.text = fh.date[indexPath.row] as? String
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = 5
        cell.layer.cornerRadius = 15
        cell.layer.borderColor = UIColor.black.cgColor
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
