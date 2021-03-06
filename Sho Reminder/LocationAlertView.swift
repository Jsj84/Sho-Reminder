//
//  LocationAlertView.swift
//  Sho Reminder
//
//  Created by Jesse on 5/27/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import UIKit
import MapKit

class LocationAlertView: UIView {
    
    var shouldSetupConstraints = true
    var mapView: MKMapView!
    var textField: UITextField!
    var cancel: UIButton!
    var enter: UIButton!
    var save: UIButton!
    var color = UIColor(netHex:0x90F7A3)
    var selectedPin:MKPlacemark? = nil
    var locationT: LocationSearchTable!
     var segmant = UISegmentedControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.cornerRadius = 10
 
        let g = UIApplication.shared.statusBarFrame.size.height + 65
        
        self.frame =  CGRect(x: (UIScreen.main.bounds.width / 2) - (UIScreen.main.bounds.width - 70) / 2, y: g, width: UIScreen.main.bounds.width - 70, height: UIScreen.main.bounds.height / 2 - 65)
        
        
        cancel = UIButton(frame: CGRect(x: 5, y: self.bounds.maxY - 40, width: self.bounds.width / 2 - 5, height: 35))
        cancel.titleLabel?.text = "Cancel"
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(UIColor.red, for: .normal)
        cancel.titleLabel?.textAlignment = .center
        cancel.backgroundColor = color
        cancel.layer.cornerRadius = 5
        
        
        
        save = UIButton(frame: CGRect(x: cancel.frame.maxX + 5, y: self.bounds.maxY - 40, width: self.bounds.width / 2 - 5, height: 35))
        save.titleLabel?.text = "Save"
        save.setTitle("Save", for: .normal)
        save.setTitleColor(UIColor.black, for: .normal)
        save.titleLabel?.textAlignment = .center
        save.backgroundColor = color
        save.layer.cornerRadius = 5
        save.setTitleColor(UIColor.blue, for: .normal)
        
        segmant = UISegmentedControl(frame: CGRect(x: 5, y: cancel.frame.origin.y - 30, width: self.bounds.width - 10, height: 25))
        segmant.insertSegment(withTitle: "On Enter", at: 0, animated: true)
        segmant.insertSegment(withTitle: "On Exit", at: 1, animated: true)
        
        
        textField = UITextField(frame: CGRect(x: 5, y: segmant.frame.origin.y - 35, width: self.bounds.width - 10, height: 30))
        textField.autocorrectionType = .default
        textField.placeholder = "Enter your reminder for this location here!reminder here"
        textField.keyboardType = .default
        textField.keyboardAppearance = .dark
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor.white
        
        mapView = MKMapView(frame: CGRect(x: 5, y: 5, width: self.bounds.width - 10 , height: self.bounds.minY.distance(to: textField.frame.origin.y) - 10))
        mapView.layer.cornerRadius = 5
    
        
        self.addSubview(mapView)
        self.addSubview(cancel)
        self.addSubview(save)
        self.addSubview(segmant)
        self.addSubview(textField)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
extension LocationAlertView: MKMapViewDelegate {
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
        
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        swipe.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipe)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
