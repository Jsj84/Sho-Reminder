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

class TimeViewController: UIViewController, UITableViewDelegate, SwitchChangedDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var userDefaults = UserDefaults.standard
    var color = UIColor(netHex:0x90F7A3)
    let fh = ManagedObject()
    
    internal func changeStateTo(isOn: Bool, row: Int) {
        if isOn == true {
            userDefaults.set(true, forKey: "\(row)")
            userDefaults.synchronize()
            print("row: \(row) switch is on")
        }
        else {
            userDefaults.set(false, forKey: "\(row)")
            userDefaults.synchronize()
            print("row: \(row) switch is off")
        }
    }
    
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
}
extension TimeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fh.timeObject.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = fh.timeObject[indexPath.row].value(forKey: "name") as! String?
        cell.myLabel_2.text = fh.timeObject[indexPath.row ].value(forKey: "dateString") as! String?
        cell.delegate = self
        cell.row = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fh.timeObject.isEmpty == true {
            return "You Don't have any upcoming reminders"
        } else {
            return "Upcoming Reminders"
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        return 50
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(fh.timeObject[indexPath.row] as NSManagedObject)
            fh.timeObject.remove(at: indexPath.row)
            do {
                try managedContext.save()
            }
            catch{print(" Sorry Jesse, had and error saving. The error is: \(error)")}
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
