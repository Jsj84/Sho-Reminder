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

class TimeViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var userDefaults = UserDefaults.standard
    var color = UIColor(netHex:0x90F7A3)

    
    var cellTitles: [NSManagedObject] = []
    var dateCell: [NSManagedObject] = []
    
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
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Items")
        
        //3
        do {
            cellTitles = try managedContext.fetch(fetchRequest)
            dateCell = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let nameToDelete = indexPath.row
//            let dateToDelete = indexPath.row
//            fh.deleteRecords(name: nameToDelete, date: dateToDelete)
//            fh.names.remove(at: indexPath.row)
//            fh.date.remove(at: indexPath.row)
//            tableView.reloadData()
//        }
//    }
}
extension TimeViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowTitle = cellTitles[indexPath.row]
        let rowDate = dateCell[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = rowTitle.value(forKey: "name") as! String?
        cell.myLabel_2.text = rowDate.value(forKey: "dateString") as! String?
        return cell 
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
