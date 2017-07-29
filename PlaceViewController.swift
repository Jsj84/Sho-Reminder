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
import CoreData

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class PlaceViewController : UIViewController, CLLocationManagerDelegate, HandleMapSearch {
    
    
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)
    var smallView = LocationAlertView()
    let blurFx = UIBlurEffect(style: UIBlurEffectStyle.dark)
    var blurFxView = UIVisualEffectView()
    var lastAnnotation = MKPointAnnotation()
    var locationSearchTable: LocationSearchTable!
    let defaults = UserDefaults()
    var selectedItem:MKPlacemark!
    var searchBar = UISearchBar()
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        smallView.isHidden = true
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as UISearchResultsUpdating
        
        
        
        searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.mapView = smallView.mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
        
        smallView.cancel.addTarget(self, action: #selector(actionForbutton), for: .touchUpInside)
        smallView.enter.addTarget(self, action: #selector(onEntry), for: .touchUpInside)
        smallView.exit.addTarget(self, action: #selector(onExit), for: .touchUpInside)
        
    }
    func onEntry(sender:UIButton) {
        var id = 0
        let enterType = "onEnter"
        let text = smallView.textField.text
        if defaults.value(forKey: "locationId") != nil {
            id = defaults.value(forKey: "locationId") as! Int
        }
        else {
            id = -1
        }
        let NsId = id as NSNumber
        let identifier = NsId.stringValue
        
        let center = CLLocationCoordinate2D(latitude: (selectedItem?.coordinate.latitude)!, longitude: (selectedItem?.coordinate.longitude)!)
        let radius = 15 as CLLocationDistance
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        // save to coreData
        self.fh.writeLocationData(latitude: selectedItem!.coordinate.latitude, longitude: selectedItem!.coordinate.longitude, mKtitle: selectedItem!.name!, mKSubTitle: selectedItem!.title!, reminderInput: (text)!, id: id, entrance: enterType)
        self.locationManager.startMonitoring(for: region)
        let changedValue = id - 1
        self.defaults.set(changedValue, forKey: "locationId")
        print(id)
        dismissKeyboard()
        smallView.textField.text?.removeAll()
        searchBar.text?.removeAll()
        smallView.isHidden = true
        blurFxView.removeFromSuperview()
        
    }
    func onExit(sender:UIButton) {
        var id = 0
        let text = smallView.textField.text
        if defaults.value(forKey: "locationId") != nil {
            id = defaults.value(forKey: "locationId") as! Int
        }
        else {
            id = -1
        }
        let NsId = id as NSNumber
        let identifier = NsId.stringValue
        
        let center = CLLocationCoordinate2D(latitude: (selectedItem?.coordinate.latitude)!, longitude: (selectedItem?.coordinate.longitude)!)
        let radius = 15 as CLLocationDistance
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        // save to coreData
        self.fh.writeLocationData(latitude: selectedItem!.coordinate.latitude, longitude: selectedItem!.coordinate.longitude, mKtitle: selectedItem!.name!, mKSubTitle: selectedItem!.title!, reminderInput: (text)!, id: id, entrance: "onExit")
        self.locationManager.startMonitoring(for: region)
        let changedValue = id - 1
        self.defaults.set(changedValue, forKey: "locationId")
        print(id)
        dismissKeyboard()
        smallView.isHidden = true
        smallView.textField.text?.removeAll()
        searchBar.text?.removeAll()
        blurFxView.removeFromSuperview()
    }
    
    func actionForbutton(sender:UIButton!) {
        dismissKeyboard()
        searchBar.text?.removeAll()
        smallView.textField.text?.removeAll()
        smallView.isHidden = true
        blurFxView.removeFromSuperview()
        mapView.removeAnnotation(lastAnnotation)
        smallView.mapView.removeAnnotation(lastAnnotation)
        mapView.reloadInputViews()
        smallView.mapView.reloadInputViews()
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
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    func dropPinZoomIn(placemark:MKPlacemark) {
        
        smallView.isHidden = false
        view.addSubview(blurFxView)
        view.addSubview(smallView)
        
        selectedPin = placemark
        selectedItem = placemark
        
        let lastAnnotation = MKPointAnnotation()
        lastAnnotation.coordinate = placemark.coordinate
        lastAnnotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            lastAnnotation.subtitle = "\(city) \(state)"
        }
        self.mapView.addAnnotation(lastAnnotation)
        smallView.mapView.addAnnotation(lastAnnotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let smallSpan = MKCoordinateSpanMake(0.011, 0.011)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        let smallRegion = MKCoordinateRegionMake(placemark.coordinate, smallSpan)
        mapView.setRegion(region, animated: true)
        smallView.mapView.setRegion(smallRegion, animated: true)
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
        
        // button.addTarget(self, action: #selector(popUpBox), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
}
