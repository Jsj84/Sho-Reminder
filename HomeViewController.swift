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
import MapKit

protocol HandleMapSearch2 {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HandleMapSearch2 {
    
      var selectedPin:MKPlacemark? = nil
    var lastAnnotation = MKPointAnnotation()
     var selectedItem:MKPlacemark!
    let locationManager = CLLocationManager()
    var fh = ManagedObject()
    var barHeight = CGFloat()
    var color = UIColor(netHex:0x90F7A3)
    var testColor = UIColor(netHex: 0x90F7A3)
    var smallView = LocationEditAlert()
    let blurFx = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
    var blurFxView = UIVisualEffectView()
    var holder = 0
    let p = PlaceViewController()
    var resultSearchController:UISearchController? = nil
    var locationSearchTable: LocationSearchTable2!
    var searchbar = UISearchBar()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    let userDefaults = UserDefaults()
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        
        selectedPin = placemark
        selectedItem = placemark
        
        self.lastAnnotation = MKPointAnnotation()
        self.lastAnnotation.coordinate = placemark.coordinate
        self.lastAnnotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            self.lastAnnotation.subtitle = "\(city) \(state)"
        }
        smallView.mapView.addAnnotation(lastAnnotation)
        let smallSpan = MKCoordinateSpanMake(0.011, 0.011)
        let smallRegion = MKCoordinateRegionMake(placemark.coordinate, smallSpan)
        smallView.mapView.setRegion(smallRegion, animated: true)
         let appendedString =  selectedItem!.name! + "\r" + selectedItem!.title!
        let attributedString = NSMutableAttributedString(string:appendedString, attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 14)!])
        let stringRange = (appendedString as NSString).range(of: selectedItem!.title!)
        attributedString.setAttributes([NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 13)!], range: stringRange)
        self.smallView.lable.attributedText = attributedString
        self.smallView.reloadInputViews()
    }
    
    @IBAction func editButton(_ sender: Any) {
        if tableView.isEditing == false {
            editButton.title = "Cancel"
            editButton.tintColor = UIColor.red
            tableView.isEditing = true
        }
        else {
            tableView.isEditing = false
            editButton.tintColor = UIColor.blue
            editButton.title = "Edit"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable2") as! LocationSearchTable2
        resultSearchController =  UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as UISearchResultsUpdating!
        
        searchbar = resultSearchController!.searchBar
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        searchbar.isHidden = true
        searchbar.placeholder = "Search to edit location"
        locationSearchTable.mapView = smallView.mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        userDefaults.set(false, forKey: "bool")
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
        self.view.backgroundColor = color
        barHeight = UIApplication.shared.statusBarFrame.size.height
        
        blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        

        self.view.addSubview(blurFxView)
        self.view.addSubview(self.smallView)
        
        smallView.isHidden = true
        blurFxView.isHidden = true
        
        smallView.cancel.addTarget(self, action: #selector(actionForbutton), for: .touchUpInside)
        smallView.update.addTarget(self, action: #selector(update), for: .touchUpInside)

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.separatorColor = UIColor.black
        tableView.backgroundView?.isOpaque = true
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.separatorColor = UIColor.green
        
        self.hideKeyboardWhenTappedAround()
    }
 
    @objc func update(sender:UIButton) {
        let id = self.fh.locationObject[holder].value(forKey: "id") as! Int
         var entance =  ""
        var tit = ""
        var subtit = ""
        var lat = 0.0
        var lng = 0.0
        if selectedItem == nil {
            tit = self.fh.locationObject[holder].value(forKey: "mKtitle") as! String
            subtit = self.fh.locationObject[holder].value(forKey: "mKSubTitle") as! String
            lat = self.fh.locationObject[holder].value(forKey: "latitude") as! Double
            lng = self.fh.locationObject[holder].value(forKey: "longitude") as! Double
            entance = self.fh.locationObject[holder].value(forKey: "entrance") as! String
        }
        else {
            tit = selectedItem.name!
            subtit = selectedItem.title!
            lat = selectedItem.coordinate.latitude
            lng = selectedItem.coordinate.longitude
        }

        if smallView.segmant.selectedSegmentIndex == 0 {
            entance = "onEntry"
        }
        else if smallView.segmant.selectedSegmentIndex == 1 {
            entance = "onExit"
        }
        let nsNum = id as NSNumber
        let numString = nsNum.stringValue
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = CLCircularRegion(center: center, radius: 25, identifier: numString)
        p.locationManager.stopMonitoring(for: region)
        
        fh.updateLocation(entrance: "\(entance)", lat: lat, lng: lng, title: tit, subtitle: subtit, id: id, reminderInput: smallView.textField.text!, index: holder)
        
        p.locationManager.startMonitoring(for: region)
        selectedItem = nil
        searchbar.text = nil 
        
        smallView.textField.text?.removeAll()
        smallView.isHidden = true
        blurFxView.isHidden = true
        editButton.title = "Edit"
        editButton.isEnabled = true
        searchbar.isHidden = true
        smallView.mapView.reloadInputViews()
        
        tableView.reloadData()
    }
    @objc func actionForbutton(sender:UIButton!) {
        smallView.textField.text?.removeAll()
        smallView.isHidden = true
        blurFxView.isHidden = true
        editButton.title = "Edit"
        editButton.isEnabled = true
          searchbar.isHidden = true
        smallView.mapView.reloadInputViews()
        selectedItem = nil
        searchbar.text = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userDefaults.removeObject(forKey: "repeat")
        userDefaults.removeObject(forKey: "temp")
        userDefaults.set(false, forKey: "bool")
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
                fh.timeObject.remove(at: i)
                do {
                    try managedContext.save()
                }
                catch{print(" Sorry Jesse, had and error saving. The error is: \(error)")}
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var stringToReturn: String?
        var locationString: String?
        
        if section == 0 {
            switch fh.timeObject.count {
            case 0: if fh.locationObject.count == 0 {stringToReturn = "No reminders scheduled"}
            else { stringToReturn = ""}
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
                locationString = ""
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
            headerVew.backgroundView?.backgroundColor = UIColor.clear
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
                cell.imageIcon.image = #imageLiteral(resourceName: "Red_Sticky")
                cell.subtitleLable.text = "Notify me at: " + "\(dateAsString)"
            case "Hourly":
                cell.imageIcon.image = #imageLiteral(resourceName: "Yellow_Sticky")
                cell.subtitleLable.text = "Repeat " + "\(repeatLable)" + " at " + "\(hourStr)" + " minutes after the hour"
            case "Daily":
                cell.imageIcon.image = #imageLiteral(resourceName: "Green_Sticky")
                cell.subtitleLable.text = "Repeat " + "\(repeatLable)" + " at " + "\(timeStr)"
            case "Weekly":
                cell.imageIcon.image = #imageLiteral(resourceName: "Blue_sticky")
                cell.subtitleLable.text = "Repeat" + " every " + "\(dateString)" + " at " + "\(timeStr)"
            case "Monthly":
                cell.imageIcon.image = #imageLiteral(resourceName: "Red_Sticky")
                cell.subtitleLable.text = "Repeat " + "\(repeatLable)" + " on the " + "\(monthStr)" + "TH" + " at" + " \(timeStr)"
            case "Yearly":
                cell.imageIcon.image = #imageLiteral(resourceName: "Green_Sticky")
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
            
            let attributedString = NSMutableAttributedString(string: appendedString, attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 14)!])
            let stringRange = (appendedString as NSString).range(of: n2)
            attributedString.setAttributes([NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 13)!], range: stringRange)
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
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            fh.getData()
            let cellID = indexPath.row
            let idInt = fh.timeObject[cellID].value(forKey: "id") as! Int64
            let newId = idInt as NSNumber
            let id = newId.stringValue
            let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: " Edit ", handler:{action, indexpath in
                self.userDefaults.set(cellID, forKey: "cellId")
                self.userDefaults.set(true, forKey: "bool")
                self.tabBarController?.selectedIndex = 2
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
        else {
            fh.getLocationData()
            let cellID = indexPath.row
            holder = cellID
            let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: " Edit ", handler:{action, indexpath in
                
                self.editButton.isEnabled = false
                self.editButton.title = ""
                
                let reminder = self.fh.locationObject[cellID].value(forKey: "reminderInput") as! String
                let lat = self.fh.locationObject[cellID].value(forKey: "latitude") as! Double
                let lng = self.fh.locationObject[cellID].value(forKey: "longitude") as! Double
                let tit = self.fh.locationObject[cellID].value(forKey: "mKtitle") as! String
                let subTit = self.fh.locationObject[cellID].value(forKey: "mKSubTitle") as! String
                let ent = self.fh.locationObject[cellID].value(forKey: "entrance") as! String
                
                if ent == "onEnter" {
                      self.smallView.segmant.selectedSegmentIndex = 0
                }
                if ent == "onExit" {
                    self.smallView.segmant.selectedSegmentIndex = 1
                }
                self.smallView.textField.text = reminder
                
                let tempPoint = MKPointAnnotation()
                tempPoint.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                tempPoint.title = tit
                tempPoint.subtitle = subTit
                
                let appendedString = tit + "\r" + subTit
                let attributedString = NSMutableAttributedString(string:appendedString, attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 14)!])
                let stringRange = (appendedString as NSString).range(of: subTit)
                attributedString.setAttributes([NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 13)!], range: stringRange)
                
               self.smallView.lable.attributedText = attributedString
               self.smallView.lable.adjustsFontForContentSizeCategory = true
               self.smallView.reloadInputViews()
                
                self.smallView.mapView.addAnnotation(tempPoint)
                let smallSpan = MKCoordinateSpanMake(0.011, 0.011)
                let smallRegion = MKCoordinateRegionMake(tempPoint.coordinate, smallSpan)
                self.smallView.mapView.setRegion(smallRegion, animated: true)
                
                self.smallView.isHidden = false
                self.blurFxView.isHidden = false
                self.searchbar.isHidden = false
                
            })
            moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
            
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
                let alert = UIAlertController(title: "Confirm", message: "Delete this Reminder?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    let managedContext = appDelegate.persistentContainer.viewContext
                    managedContext.delete(self.fh.locationObject[cellID] as NSManagedObject)
                    self.fh.locationObject.remove(at: indexPath.row)
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
