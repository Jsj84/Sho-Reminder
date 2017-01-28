//
//  ViewController.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/24/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import UserNotifications

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)
    
    @IBOutlet weak var way: UILabel!
    @IBOutlet weak var place: UIButton!
    @IBOutlet weak var time: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func timeAction(_ sender: Any) {
        performSegue(withIdentifier: "timeSegue", sender: self)
    }
    @IBAction func placeAction(_ sender: Any) {
        performSegue(withIdentifier: "placeSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SectionTwoCell.self, forCellReuseIdentifier: "cell")
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.green
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        way.font = UIFont (name: "HelveticaNeue-Bold", size: 19)!
        
        place.layer.cornerRadius = 8
        place.backgroundColor = color
        place.titleLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 18)!
        place.setTitle("Place", for: .normal)
        
        time.layer.cornerRadius = 8
        time.backgroundColor = color
        time.titleLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 18)!
        time.setTitle("Time", for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = color
        tableView.backgroundView?.isOpaque = true
        tableView.allowsSelection = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fh.getData()
        fh.getLocationData()
        let now = Date()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        for i in 0..<fh.timeObject.count {
            let c = fh.timeObject[i].value(forKey: "date") as! Date
            if c <= now as Date {
                managedContext.delete(fh.timeObject[i] as NSManagedObject)
                do {
                    try managedContext.save()
                    fh.getData()
                }
                catch{print(" Sorry Jesse, had and error saving. The error is: \(error)")}
            }
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if fh.timeObject.isEmpty == true {
                return "You do not have any upcoming reminders"
            }
            else if fh.timeObject.count == 1 {
                return "You have 1 reminder scheduled"
            }
            else if fh.timeObject.count < 3 {
                return "You have " + "\(fh.timeObject.count)" + " reminders scheduled"
            }
            else {
                return "Your next 3 reminders are"
            }
        }
        else if section == 1 {
            if fh.locationObject.isEmpty == true {
                return "You do not have any upcoming location reminders"
            }
            else if fh.locationObject.count == 1 {
                return "You have 1 location reminder scheduled"
            }
        }
        return "You have " + "\(fh.locationObject.count)" + " location reminders scheduled"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        else  {
            return 55
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fh.timeObject.count
        }
        else {
            return fh.locationObject.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SectionTwoCell
            cell.nameLable.text = fh.timeObject[indexPath.row].value(forKey: "name") as! String?
            cell.subtitleLable.text = fh.timeObject[indexPath.row ].value(forKey: "dateString") as! String?
            cell.backgroundColor = UIColor.clear
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SectionTwoCell
            cell.nameLable.text = fh.locationObject[indexPath.row].value(forKey: "mKtitle") as! String?
            cell.subtitleLable.text = fh.locationObject[indexPath.row].value(forKey: "mKSubTitle") as! String?
            cell.backgroundColor = UIColor.clear
            return cell
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            if indexPath.section == 0 {
                managedContext.delete(fh.timeObject[indexPath.row] as NSManagedObject)
                fh.timeObject.remove(at: indexPath.row)
            }
            else {
                let t = fh.locationObject[indexPath.row].value(forKey: "reminderInput") as! String?
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: t!), object: nil)
                managedContext.delete(fh.locationObject[indexPath.row] as NSManagedObject)
                fh.locationObject.remove(at: indexPath.row)
            }
            do {
                try managedContext.save()
            }
            catch{print(" Sorry Jesse, had and error saving. The error is: \(error)")}
            tableView.reloadData()
        }
    }
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
