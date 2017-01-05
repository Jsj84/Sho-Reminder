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

protocol HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark)
}
class PlaceViewController : UIViewController, CLLocationManagerDelegate, HandleMapSearch {
    
    let searchRadius: CLLocationDistance = 2000
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var center = CLLocationCoordinate2D()
    var coordinates: [CLLocationCoordinate2D] = []
    var resultSearchController:UISearchController? = nil
    let fh = ManagedObject()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fh.getLocationData()
        
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
        
        for index in 0..<fh.latitude.count {
            let lat = Double(fh.latitude[index])
            let long = Double(fh.longitude[index])
            let t =  fh.tite[index]
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let placeMark:MKPlacemark = MKPlacemark(coordinate: location)
            
            selectedPin = placeMark
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = (selectedPin?.coordinate)!
            annotation.title = t
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
            if CLLocationManager.isRangingAvailable() {
                locationManager.startUpdatingLocation()
                locationManager.distanceFilter = 10
                for i in 0..<self.fh.latitude.count {
                    let lat = fh.latitude[i]
                    let long = fh.longitude[i]
                    let radius = 50
                    let coordinatesToAppend = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    coordinates.append(coordinatesToAppend)
                    center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let region = CLCircularRegion.init(center: center, radius: CLLocationDistance(radius), identifier: "\(fh.latitude[i])")
                    locationManager.startMonitoring(for: region)
                }
            }
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.10, 0.10)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
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
        content.title = NSString.localizedUserNotificationString(forKey: "Region Entered", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "You have entered: \(region.identifier)", arguments: nil)
        content.sound = UNNotificationSound.default()
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
