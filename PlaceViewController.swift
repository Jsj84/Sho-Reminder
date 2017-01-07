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
    
    var lati: [NSManagedObject] = []
    var longi: [NSManagedObject] = []
    var mKtit: [NSManagedObject] = []
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let locationRequest = NSFetchRequest<NSManagedObject>(entityName: "Locations")
        
        do {
            
            lati = try managedContext.fetch(locationRequest)
            longi = try managedContext.fetch(locationRequest)
            mKtit = try managedContext.fetch(locationRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for index in 0..<lati.count {
            let lat = lati[index].value(forKey: "latitude") as! Double?
            let long = longi[index].value(forKey: "longitude") as! Double?
            
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            let placeMark:MKPlacemark = MKPlacemark(coordinate: location)
            
            selectedPin = placeMark
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = (selectedPin?.coordinate)!
            annotation.title = mKtit[index].value(forKey: "mKtitle") as! String?
            
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
            for i in 0..<lati.count {
                let lat = lati[i].value(forKey: "latitude") as! Double?
                let long = longi[i].value(forKey: "longitude") as! Double?
                let radius = 30
                let coordinatesToAppend = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                coordinates.append(coordinatesToAppend)
                center = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                let region = CLCircularRegion.init(center: center, radius: CLLocationDistance(radius), identifier: "\(lati[i])")
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
        print("Region: \(region.identifier)" + " is being monitored")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = "Location Reminder"
        content.subtitle = "\(selectedPin?.title)"
        content.body = "Configured test notifications!"
        content.sound = UNNotificationSound.default()
        
        // Deliver the notification in one second.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let reqest = UNNotificationRequest(identifier: "requestIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(reqest){(error) in
            
            if (error != nil){
                print(error?.localizedDescription as Any)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Region Exited", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "You have Exited: \(region.identifier)", arguments: nil)
        content.sound = UNNotificationSound.default()
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
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (_) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let locationRequest = NSFetchRequest<NSManagedObject>(entityName: "Locations")
            
            do {
                self.lati = try managedContext.fetch(locationRequest)
                self.longi = try managedContext.fetch(locationRequest)
                self.mKtit = try managedContext.fetch(locationRequest)
                print(locationRequest)
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
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
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        let rightButton = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(#imageLiteral(resourceName: "checkList"), for: .normal)
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "delete"), for: .normal)
        
        button.addTarget(self, action: #selector(presentAlert), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(deleteAlert), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        pinView?.rightCalloutAccessoryView = rightButton
        return pinView
    }
    
}
