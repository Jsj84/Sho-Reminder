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
    let calendaer = Calendar.current
    
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
        let titleOne = fh.timeObject[indexPath.row].value(forKey: "name") as! String
        let repeatLable = fh.timeObject[indexPath.row].value(forKey: "repeatOption") as! String
        let dateAsString = fh.timeObject[indexPath.row].value(forKey: "dateString") as! String
        let chosenDate = fh.timeObject[indexPath.row].value(forKey: "date") as! Date
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = titleOne
        
        let formatter = DateFormatter()
        let dayFormatter = DateFormatter()
        let yearlyFormatter = DateFormatter()
        let hourlyFormatter = DateFormatter()
        let monthlyFormatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        dayFormatter.dateFormat = "MMMM d"
        hourlyFormatter.dateFormat = "mm"
        yearlyFormatter.timeStyle = .short
        monthlyFormatter.dateFormat = "d"
        let dateString = formatter.string(from: chosenDate)
        let monthYear = dayFormatter.string(from: chosenDate)
        let timeStr = yearlyFormatter.string(from: chosenDate)
        let hourStr = hourlyFormatter.string(from: chosenDate)
        let monthStr = monthlyFormatter.string(from: chosenDate)
        
        switch repeatLable {
        case "Never":
            cell.myLabel_2.text = "Notify me at: " + "\(dateAsString)"
        case "Hourly":
            cell.myLabel_2.text = "Repeat " + "\(repeatLable)" + " at " + "\(hourStr)" + " minutes after the hour"
        case "Daily":
            cell.myLabel_2.text = "Repeat " + "\(repeatLable)" + " at " + "\(timeStr)"
        case "Weekly":
            cell.myLabel_2.text = "Repeat" + " every " + "\(dateString)" + " at " + "\(timeStr)"
        case "Monthly":
            cell.myLabel_2.text = "Repeat " + "\(repeatLable)" + " on the " + "\(monthStr)" + "TH" + " at" + " \(timeStr)"
        case "Yearly":
            cell.myLabel_2.text = "Repeat " + "\(repeatLable)" + " on " + "\(monthYear)" + " at " + "\(timeStr)"
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
            
            let t = fh.timeObject[indexPath.row].value(forKey: "name") as! String
            let aD = AppDelegate()
            aD.deleteNotification(identifier: t)
            
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
