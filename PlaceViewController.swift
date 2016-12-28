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

class PlaceViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var discriptionTextField: UITextField!
    @IBOutlet weak var myMapView: MKMapView!
    
    var resultSearchController:UISearchController? = nil
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

     func locationManager(_manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            myMapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
}
