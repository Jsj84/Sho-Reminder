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

class TimeViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var reminderName: UILabel!
    @IBOutlet weak var reminderDiscription: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var textEntered:[String] = []
    var t:NSMutableArray = NSMutableArray()
    var fh = ManagedObject()

    let defaults = UserDefaults.standard
    
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
            let alert = UIAlertController(title: "Alert", message: "You cannot save this reminder without a discription", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.view.endEditing(true)
            fh.writeData(Items: "Items", name: textField.text!)
            fh.finalNames.append(textField.text!)
            reminderDiscription.text?.removeAll()
            
          //  let dateOnPicker = timePicker.date //capture the date shown on the picker
//            let dateFormatter = DateFormatter() //create a date formatter
//            
//            dateFormatter.dateStyle = DateFormatter.Style.short
//            dateFormatter.timeStyle = DateFormatter.Style.short
            
         //   let timeString = dateFormatter.string(from: dateOnPicker)
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
        return fh.finalNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = fh.finalNames[indexPath.row]
      //  cell.myLabel_2.text = timeAsString[row]
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = 5
        cell.layer.cornerRadius = 15
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fh.finalNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
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
