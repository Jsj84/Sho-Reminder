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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)
    let locationManager = CLLocationManager()
    
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.green
        
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Corkboard_BG"))
        
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
        let now = Date()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        for i in 0..<fh.timeObject.count {
            let t = fh.timeObject[i].value(forKey: "name") as! String
            let c = fh.timeObject[i].value(forKey: "date") as! Date
            let r = fh.timeObject[i].value(forKey: "repeatOption") as! String
            if c <= now as Date && r == "Never" {
                appDelegate.deleteNotification(identifier: t)
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
                stringToReturn = "You do not have any upcoming reminders"; break
            case 1 :
                stringToReturn = "You have 1 reminder scheduled"; break
            default:
                stringToReturn = "You have " + "\(fh.timeObject.count)" + " reminders scheduled"; break
            }
            return stringToReturn
        }
        if section == 1 {
            switch fh.locationObject.count {
            case 0:
                locationString = "no location reminders scheduled"; break
            case 1 :
                locationString = "1 location reminder Scheduled"; break
            default:
                locationString = "\(fh.locationObject.count)" + " Location reminders scheduled"; break
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
            cell.nameLable.text = fh.locationObject[indexPath.row].value(forKey: "mKtitle") as! String?
            cell.subtitleLable.text = fh.locationObject[indexPath.row].value(forKey: "mKSubTitle") as! String?
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
                let t = fh.timeObject[indexPath.row].value(forKey: "name") as! String
                let appDelegate = AppDelegate()
                appDelegate.deleteNotification(identifier: t)
                
                managedContext.delete(fh.timeObject[indexPath.row] as NSManagedObject)
                fh.timeObject.remove(at: indexPath.row)
            }
            else {
                let l = fh.locationObject[indexPath.row].value(forKey: "mKtitle") as! String
                let g = fh.locationObject[indexPath.row].value(forKey: "reminderInput") as! String
                let appDelegate = AppDelegate()
                appDelegate.deleteNotification(identifier: l)
                appDelegate.deleteNotification(identifier: g)
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            let alert = UIAlertController(title: "Warning", message: "Location updates are required for this app to set reminders based on location. You can configure this is settings.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if status == .authorizedAlways {
            fh.getLocationData()
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 5
            var center = CLLocationCoordinate2D()
            for i in 0..<self.fh.locationObject.count {
                let lat = fh.locationObject[i].value(forKey: "latitude") as! Double
                let long = fh.locationObject[i].value(forKey: "longitude") as! Double
                let reminder = fh.locationObject[i].value(forKey: "reminderInput") as! String
                let radius:CLLocationDistance = 20
                center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let region = CLCircularRegion.init(center: center, radius: radius, identifier: reminder)
                locationManager.startMonitoring(for: region)
                print("Region: \(region.identifier)" + " is being monitored")
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) { 
        locationManager.delegate = self
        region.notifyOnExit = true
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager.delegate = self
        region.notifyOnEntry = true
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        region.notifyOnExit = true
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
