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
    var cellImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addBackground()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
        tableView.separatorColor = UIColor.black
        
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userDefaults.set(false, forKey: "bool")
        fh.getData()
        tableView.reloadData()
    }
    func randomImage() -> UIImage {
        let imageSet:[UIImage] = [#imageLiteral(resourceName: "Red_Sticky"),#imageLiteral(resourceName: "Green_Sticky"),#imageLiteral(resourceName: "Blue_sticky"),#imageLiteral(resourceName: "Yellow_Sticky")]
        let randomImage = Int(arc4random_uniform(UInt32(imageSet.count)))
        let generatedImage = imageSet[randomImage]
        return generatedImage
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
        cell.myLabel_2.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        
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
        cell.cellImage.image = randomImage()
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fh.timeObject.isEmpty == true {
            return "No reminders are scheduled"
        } else {
            return "Scheduled Reminders"
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.black
            headerView.backgroundView?.backgroundColor = color
            headerView.textLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 14)!}
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        fh.getData()
        let cellID = indexPath.row
        let idInt = fh.timeObject[cellID].value(forKey: "id") as! Int
        let newId = idInt as NSNumber
        let id = newId.stringValue
        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: " Edit ", handler:{action, indexpath in
            self.userDefaults.set(cellID, forKey: "cellId")
            self.userDefaults.set(true, forKey: "bool")
            self.performSegue(withIdentifier: "addSegue", sender: nil)
        })
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            let alert = UIAlertController(title: "Confirm", message: "Delete this Reminder?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.persistentContainer.viewContext
                appDelegate.deleteNotification(identifier: id)
                managedContext.delete(self.fh.timeObject[cellID] as NSManagedObject)
                self.fh.timeObject.remove(at: indexPath.row)
                do {
                    try managedContext.save()
                }
                catch{print(" Sorry Jesse, had and error saving. The error is: \(error)")}
                tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            }))
            self.present(alert, animated: true, completion: nil)
        })
        return [deleteRowAction, moreRowAction]
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.setEditing(true, animated: true)
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
