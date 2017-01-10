//
//  PlaceViewController.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/25/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import UserNotifications
import CoreData

protocol HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark)
}
class PlaceViewController : UIViewController, CLLocationManagerDelegate, HandleMapSearch, UNUserNotificationCenterDelegate {
    
    let searchRadius: CLLocationDistance = 2000
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var center = CLLocationCoordinate2D()
    var coordinates: [CLLocationCoordinate2D] = []
    var resultSearchController:UISearchController? = nil
    let fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popUPView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    @IBAction func cancelAction(_ sender: Any) {
        tableView.isHidden = true
        cancelB.isHidden = true
        popUPView.isHidden = true
        saveB.isHidden = true
    }
    @IBOutlet weak var saveAction: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUPView.isHidden = true
        popUPView.layer.cornerRadius = 10
        popUPView.layer.masksToBounds = true
        
        tableView.isHidden = true
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        
        cancelB.backgroundColor = color
        cancelB.layer.cornerRadius = 8
        cancelB.isHidden = true
        saveB.backgroundColor = color
        saveB.layer.cornerRadius = 8
        saveB.isHidden = true
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fh.getLocationData()
        
        for index in 0..<fh.locationObject.count {
            let lat = fh.locationObject[index].value(forKey: "latitude") as! Double?
            let long = fh.locationObject[index].value(forKey: "longitude") as! Double?
            
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            let placeMark:MKPlacemark = MKPlacemark(coordinate: location)
            
            selectedPin = placeMark
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = (selectedPin?.coordinate)!
            annotation.title = fh.locationObject[index].value(forKey: "mKtitle") as! String?
            
            if let city = selectedPin?.locality,
                let state = selectedPin?.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
            }
            self.mapView.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(placeMark.coordinate, span)
            mapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            let alert = UIAlertController(title: "Warning", message: "Location updates are required for this app to set reminders based on location. You can configure this is settings.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 10
            
            for i in 0..<fh.locationObject.count {
                let lat = fh.locationObject[i].value(forKey: "latitude") as! Double
                let long = fh.locationObject[i].value(forKey: "longitude") as! Double
                let radius:CLLocationDistance = 30
                center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let region = CLCircularRegion.init(center: center, radius: radius, identifier: "\(lat)")
                locationManager.startMonitoring(for: region)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        region.notifyOnEntry = true
        region.notifyOnExit = true
        print("Region: \(region.identifier)" + " is being monitored")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey:
            "REMINDER!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey:
            "You have entered: \(region.identifier)", arguments: nil)
        
        // Deliver the notification in two seconds.
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: "TwoSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey:
            "REMINDER!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey:
            "You have Exited: \(region.identifier)", arguments: nil)
        
        // Deliver the notification in two seconds.
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: "TwoSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    func dropPinZoomIn(placemark:MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        self.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    func presentAlert() {
        let alertController = UIAlertController(title: "Reminder", message: "Please enter the description of this reminder you will receive upon entering this location", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                // store your data
                print(field)
            } else {
                // user did not fill field
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "reminder description"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func deleteAlert(){
        let alertController = UIAlertController(title: "DELETE", message: "Are you sure you would like to delete this location?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (_) in }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func showPop() {
        popUPView.isHidden = false
        tableView.isHidden = false
        tableView.alpha = 1.0
        popUPView.alpha = 1.0
        cancelB.isHidden = false
        saveB.isHidden = false
        //        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UIMenuController.update), userInfo: nil, repeats: false)
        
    }
    func update() {
        //  PopUpView.hidden = true
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.popUPView.alpha = 0.0
        }, completion: nil)
        
    }
}
extension PlaceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.green
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        let rightButton = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(#imageLiteral(resourceName: "checkList"), for: .normal)
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "delete"), for: .normal)
        
        button.addTarget(self, action: #selector(showPop), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(deleteAlert), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        pinView?.rightCalloutAccessoryView = rightButton
        return pinView
    }
    
}
extension PlaceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PopUpViewCell
        return cell 
    }
}
