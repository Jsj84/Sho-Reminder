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
    
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fh.getLocationData()
        for i in 0..<fh.locationObject.count {
            let lat = fh.locationObject[i].value(forKey: "latitude") as! Double?
            let long = fh.locationObject[i].value(forKey: "longitude") as! Double?
            
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            let placeMark:MKPlacemark = MKPlacemark(coordinate: location)
            
            selectedPin = placeMark
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = (selectedPin?.coordinate)!
            annotation.title = fh.locationObject[i].value(forKey: "mKtitle") as! String?
            
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
            fh.getLocationData()
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 10
            var center = CLLocationCoordinate2D()
            for i in 0..<self.fh.locationObject.count {
                let lat = fh.locationObject[i].value(forKey: "latitude") as! Double
                let long = fh.locationObject[i].value(forKey: "longitude") as! Double
                let reminder = fh.locationObject[i].value(forKey: "reminderInput") as! String
                let radius:CLLocationDistance = 30
                center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let region = CLCircularRegion.init(center: center, radius: radius, identifier: reminder)
                locationManager.startMonitoring(for: region)
                print("Region: \(region.identifier)" + " is being monitored")
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
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.locationManager.delegate = self
//        delegate?.locationNotification(title: "Location Reminder", body: region.identifier, identifer: region.identifier)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.locationManager.delegate = self
       // delegate?.locationNotification(title: "Location Reminder", body: region.identifier, identifer: region.identifier)
    }
    func dropPinZoomIn(placemark:MKPlacemark) {
        
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
    func popUpBox(){
        print("test for popup box")
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
        button.setBackgroundImage(#imageLiteral(resourceName: "checkList"), for: .normal)
        
        button.addTarget(self, action: #selector(popUpBox), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
}
