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
    var exit: UIButton!
    var color = UIColor(netHex:0x90F7A3)
    var selectedPin:MKPlacemark? = nil
    var locationT: LocationSearchTable!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.cornerRadius = 10
        
        mapView = MKMapView(frame: CGRect(x: 5, y: 5, width: self.bounds.width - 10 , height: 130))
        mapView.layer.cornerRadius = 5
        self.addSubview(mapView)
    
        
        textField = UITextField(frame: CGRect(x: 5, y: 155, width: self.bounds.width - 10, height: 35))
        textField.autocorrectionType = .default
        textField.placeholder = "Enter reminder here"
        textField.keyboardType = .default
        textField.keyboardAppearance = .dark
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor.white
        self.addSubview(textField)
        
        cancel = UIButton(frame: CGRect(x: 5, y: self.bounds.maxY - 40, width: self.bounds.width - 10, height: 35))
        cancel.titleLabel?.text = "Cancel"
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(UIColor.red, for: .normal)
        cancel.titleLabel?.textAlignment = .center
        cancel.backgroundColor = color
        cancel.layer.cornerRadius = 5
        self.addSubview(cancel)
        
        
        exit = UIButton(frame: CGRect(x: 5, y:  self.bounds.maxY - 80, width: self.bounds.width  / 2 - 5, height: 35))
        exit.titleLabel?.text = "On Exit"
        exit.setTitle("On Exit", for: .normal)
        exit.setTitleColor(UIColor.black, for: .normal)
        exit.titleLabel?.textAlignment = .center
        exit.backgroundColor = color
        exit.layer.cornerRadius = 5
        self.addSubview(exit)
        
        
        enter = UIButton(frame: CGRect(x: exit.bounds.width + 10, y: self.bounds.maxY - 80, width: exit.bounds.width - 5, height: 35))
        enter.titleLabel?.text = "On Enter"
        enter.setTitle("On Enter", for: .normal)
        enter.setTitleColor(UIColor.black, for: .normal)
        enter.titleLabel?.textAlignment = .center
        enter.backgroundColor = color
        enter.layer.cornerRadius = 5
        self.addSubview(enter)        
        
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
        
        // button.addTarget(self, action: #selector(popUpBox), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
}
}
