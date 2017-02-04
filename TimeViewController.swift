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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = fh.timeObject[indexPath.row].value(forKey: "name") as! String?
        if fh.timeObject[indexPath.row].value(forKey: "repeatOption") as! String == "Never" {
           cell.myLabel_2.text = fh.timeObject[indexPath.row ].value(forKey: "dateString") as! String?
        }
        else {
            let repeatLable = fh.timeObject[indexPath.row].value(forKey: "repeatOption") as! String
            var timeLable = fh.timeObject[indexPath.row].value(forKey: "dateString") as! String
            while timeLable.characters.count > 8 {
                    timeLable.characters.removeFirst()
            }
            cell.myLabel_2.text = "\(repeatLable)" + "\(timeLable)"
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
