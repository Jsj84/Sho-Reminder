//
//  TimeAddViewController.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/3/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

class TimeAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)

    let tableData = ["Repeat", "Time Zone"]
    
    var notifyDate:[Date] = []
    var notifyBody:[String] = []
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
            
            let dateOnPicker = timePicker.date //capture the date shown on the picker
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateAsString = dateFormatter.string(from: dateOnPicker)
            
            let delegate = UIApplication.shared.delegate as? AppDelegate

            delegate?.scheduleNotification(atDate: dateOnPicker, body: reminderDiscription.text!)
            fh.writeData(Items: "Items", name: reminderDiscription.text!, date: dateOnPicker, dateString: dateAsString)
            fh.names.append(reminderDiscription.text! as NSObject)
            fh.dateString.append(dateAsString)
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
}
