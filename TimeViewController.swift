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

class TimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var userDefaults = UserDefaults.standard
    var color = UIColor(netHex:0x90F7A3)
    let fh = ManagedObject()
    var c:[NSManagedObject] = []
    let today = NSDate()
    let calendaer = NSCalendar(identifier: .gregorian)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
        tableView.separatorColor = color
        
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fh.getData()
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fh.timeObject.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fh.getData()
        let repeatLable = fh.timeObject[indexPath.row].value(forKey: "repeatOption") as! String
        let dateAsString = fh.timeObject[indexPath.row].value(forKey: "dateString") as! String
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = fh.timeObject[indexPath.row].value(forKey: "name") as! String?
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dateString = formatter.string(from: today as Date)
        
        switch repeatLable {
        case "Never":
            cell.myLabel_2.text = "Notify me at: " + "\(dateAsString)"
        case "Hourly":
            let startIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 7)
            let endIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 12)
            let str = dateAsString[startIndex...endIndex]
            cell.myLabel_2.text = "Repeat " + "\(repeatLable)" + " from " + "\(str)"
        case "Daily":
            let startIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 7)
            let endIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 14)
            let str = dateAsString[startIndex...endIndex]
            cell.myLabel_2.text = "Repeat " + "\(repeatLable)" + " at " + "\(str)"
        case "Weekly":
            let startIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 7)
            let endIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 14)
            let str = dateAsString[startIndex...endIndex]
            cell.myLabel_2.text = "Repeat "  + "\(repeatLable)" + " every " + "\(dateString)" + " at " + "\(str)"
        case "Monthly":
            let startIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 2)
            let endIndex = dateAsString.index(dateAsString.startIndex, offsetBy: 2)
            let str = dateAsString[startIndex...endIndex]
            cell.myLabel_2.text = "Repeat " + "\(repeatLable)" + " on the " + "\(str)" + "TH"
        default: break
        }
        cell.cellImage.image = #imageLiteral(resourceName: "StickyNote")
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
