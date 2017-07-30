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
import CoreLocation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let locationManager = CLLocationManager()
    var fh = ManagedObject()
    
    var color = UIColor(netHex:0x90F7A3)
    
    @IBOutlet weak var way: UILabel!
    @IBOutlet weak var place: UIButton!
    @IBOutlet weak var time: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func timeAction(_ sender: Any) {
        performSegue(withIdentifier: "timeSegue", sender: self)
    }
    @IBAction func placeAction(_ sender: Any) {
        performSegue(withIdentifier: "placeSegue", sender: self)
    }
    @IBAction func editButton(_ sender: Any) {
        if tableView.isEditing == false {
            editButton.title = "Done"
            tableView.isEditing = true
        }
        else {
            tableView.isEditing = false
            editButton.title = "Edit"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fh.getData()
        fh.getLocationData()
        if fh.timeObject.isEmpty == true && fh.locationObject.isEmpty == true {
            editButton.isEnabled = false
            editButton.title = ""
        }
        else {
            editButton.title = "Edit"
            editButton.isEnabled = true
        }
        self.navigationController?.navigationBar.backgroundColor = UIColor.green
        self.view.addBackground()
        
        way.font = UIFont (name: "HelveticaNeue-Bold", size: 22)!
        way.textColor = UIColor.black
        
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
        tableView.separatorColor = UIColor.black
        tableView.backgroundView?.isOpaque = true
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fh.getData()
        fh.getLocationData()
        tableView.reloadData()
        if fh.timeObject.isEmpty == true && fh.locationObject.isEmpty == true {
            editButton.title = ""
            editButton.isEnabled = false
        }
        else {
            editButton.title = "Edit"
            editButton.isEnabled = true
        }
        let now = Date()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        for i in 0..<fh.timeObject.count {
            let idInt = fh.timeObject[i].value(forKey: "id") as! Int
            let newId = idInt as NSNumber
            let id = newId.stringValue
            let c = fh.timeObject[i].value(forKey: "date") as! Date
            let r = fh.timeObject[i].value(forKey: "repeatOption") as! String
            if c <= now as Date && r == "Never" {
                appDelegate.deleteNotification(identifier: id)
                managedContext.delete(fh.timeObject[i] as NSManagedObject)
                do {
                    try managedContext.save()
                }
                catch{print(" Sorry Jesse, had and error saving. The error is: \(error)")}
            }
        }
        fh.getData()
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var stringToReturn: String?
        var locationString: String?
        
        if section == 0 {
            switch fh.timeObject.count {
            case 0:
                stringToReturn = "No reminders scheduled"
            case 1 :
                stringToReturn = "1 reminder scheduled"
            default:
                stringToReturn = "\(fh.timeObject.count)" + " reminders scheduled"; break
            }
            return stringToReturn
        }
        if section == 1 {
            switch fh.locationObject.count {
            case 0:
                locationString = "no location reminders scheduled"
            case 1 :
                locationString = "1 location reminder Scheduled"
            default:
                locationString = "\(fh.locationObject.count)" + " Location reminders scheduled"
                break
            }
        }
        return locationString
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerVew = view as? UITableViewHeaderFooterView {
            headerVew.backgroundView?.backgroundColor = color
            headerVew.textLabel?.textColor = UIColor.black
            headerVew.textLabel?.textAlignment = .left
            headerVew.textLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 14)!
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
            let titleOne = fh.timeObject[indexPath.row].value(forKey: "name") as! String
            let repeatLable = fh.timeObject[indexPath.row].value(forKey: "repeatOption") as! String
            let dateAsString = fh.timeObject[indexPath.row].value(forKey: "dateString") as! String
            let chosenDate = fh.timeObject[indexPath.row].value(forKey: "date") as! Date
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SectionTwoCell
            cell.nameLable.text = titleOne
            cell.backgroundColor = UIColor.clear
            cell.imageIcon.image = #imageLiteral(resourceName: "Clock_Icon")
            cell.entranceOrExit.isHidden = true
            
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
                cell.subtitleLable.text = "Notify me at: " + "\(dateAsString)"
            case "Hourly":
                cell.subtitleLable.text = "Repeat " + "\(repeatLable)" + " at " + "\(hourStr)" + " minutes after the hour"
            case "Daily":
                cell.subtitleLable.text = "Repeat " + "\(repeatLable)" + " at " + "\(timeStr)"
            case "Weekly":
                cell.subtitleLable.text = "Repeat" + " every " + "\(dateString)" + " at " + "\(timeStr)"
            case "Monthly":
                cell.subtitleLable.text = "Repeat " + "\(repeatLable)" + " on the " + "\(monthStr)" + "TH" + " at" + " \(timeStr)"
            case "Yearly":
                cell.subtitleLable.text = "Repeat " + "\(repeatLable)" + " on " + "\(monthYear)" + " at " + "\(timeStr)"
            default: break
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SectionTwoCell
            let n = fh.locationObject[indexPath.row].value(forKey: "mKtitle") as! String
            let n2 = fh.locationObject[indexPath.row].value(forKey: "reminderInput") as! String
            let appendedString =  n + "\r" + n2
            
            let attributedString = NSMutableAttributedString(string: appendedString, attributes: [NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: 14)!])
            let stringRange = (appendedString as NSString).range(of: n2)
            attributedString.setAttributes([NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 13)!, NSForegroundColorAttributeName : UIColor.black], range: stringRange)
            cell.nameLable.attributedText = attributedString
            cell.subtitleLable.text = fh.locationObject[indexPath.row].value(forKey: "mKSubTitle") as! String?
            let tempVal = fh.locationObject[indexPath.row].value(forKey: "entrance") as! String?
            if tempVal == "onEnter" {
                cell.entranceOrExit.text = "On Enter"
            }
            else {
                cell.entranceOrExit.text = "On Exit"
            }
            cell.imageIcon.image = #imageLiteral(resourceName: "Location_Icon")
            cell.backgroundColor = UIColor.clear
            return cell
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            if indexPath.section == 0 {
                fh.getData()
                let idInt = fh.timeObject[indexPath.row].value(forKey: "id") as! Int
                let newId = idInt as NSNumber
                let id = newId.stringValue
                print(id)
                let appDelegate = AppDelegate()
                appDelegate.deleteNotification(identifier: id)
                
                managedContext.delete(fh.timeObject[indexPath.row] as NSManagedObject)
                fh.timeObject.remove(at: indexPath.row)
            }
            else {
                fh.getLocationData()
                let id = fh.locationObject[indexPath.row].value(forKey: "id") as! Int
                let nsNum = id as NSNumber
                let numString = nsNum.stringValue
                
                let latitude = fh.locationObject[indexPath.row].value(forKey: "latitude") as! Double
                let longitude = fh.locationObject[indexPath.row].value(forKey: "longitude") as! Double
                let radius:CLLocationDistance = 25
                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let region = CLCircularRegion(center: center, radius: radius, identifier: numString)
                locationManager.stopMonitoring(for: region)
                print("region with identifer " + numString + " is no longer being monitored for")
                
                let appDelegate = AppDelegate()
                appDelegate.deleteNotification(identifier: numString)
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
