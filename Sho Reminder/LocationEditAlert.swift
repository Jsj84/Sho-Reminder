//
//  LocationAlertView.swift
//  Sho Reminder
//
//  Created by Jesse on 5/27/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import UIKit
import MapKit

class LocationEditAlert: UIView {
    
    var shouldSetupConstraints = true
    var mapView: MKMapView!
    var textField: UITextField!
    var cancel: UIButton!
    var update: UIButton!
    var lable: UILabel!
    var color = UIColor(netHex:0x90F7A3)
    var selectedPin:MKPlacemark? = nil
    var locationT: LocationSearchTable!
    var k = CGFloat()
    var segmant = UISegmentedControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.cornerRadius = 10
        
        let g = UIApplication.shared.statusBarFrame.size.height + 65
        
        self.frame =  CGRect(x: (UIScreen.main.bounds.width / 2) - (UIScreen.main.bounds.width - 70) / 2, y: g, width: UIScreen.main.bounds.width - 70, height: UIScreen.main.bounds.height / 2 - 50)
        
        lable = UILabel(frame: CGRect(x: 5, y: 5, width: self.bounds.width - 10, height: 50))
        lable.adjustsFontSizeToFitWidth = true
        lable.numberOfLines = 2
        lable.backgroundColor = color
        
        mapView = MKMapView(frame: CGRect(x: 5, y: 60, width: self.bounds.width - 10 , height: self.bounds.height / 2))
        mapView.layer.cornerRadius = 5
        
        
        cancel = UIButton(frame: CGRect(x: 5, y: self.bounds.maxY - 40, width: self.bounds.width / 2 - 10, height: 35))
        cancel.titleLabel?.text = "Cancel"
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(UIColor.red, for: .normal)
        cancel.titleLabel?.textAlignment = .center
        cancel.backgroundColor = color
        cancel.layer.cornerRadius = 5
        
        update = UIButton(frame: CGRect(x: self.bounds.width / 2 + 5, y: self.bounds.maxY - 40, width: self.bounds.width / 2 - 10, height: 35))
        update.titleLabel?.text = "Update"
        update.setTitle("Update", for: .normal)
        update.setTitleColor(UIColor.blue, for: .normal)
        update.titleLabel?.textAlignment = .center
        update.backgroundColor = color
        update.layer.cornerRadius = 5
        
        segmant = UISegmentedControl(frame: CGRect(x: 5, y: update.frame.minY - 30, width: self.bounds.width - 10, height: 25))
        segmant.insertSegment(withTitle: "On Enter", at: 0, animated: true)
        segmant.insertSegment(withTitle: "On Exit", at: 1, animated: true)
        
        textField = UITextField(frame: CGRect(x: 5, y: mapView.frame.maxY + 5, width: self.bounds.width - 10, height: mapView.frame.maxY.distance(to: segmant.frame.origin.y) - 10))
        textField.autocorrectionType = .default
        textField.placeholder = "Enter your reminder for this location here!reminder here"
        textField.keyboardType = .default
        textField.keyboardAppearance = .dark
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor.white
        
        self.addSubview(lable)
        self.addSubview(mapView)
        self.addSubview(cancel)
        self.addSubview(update)
        self.addSubview(textField)
         self.addSubview(segmant)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

