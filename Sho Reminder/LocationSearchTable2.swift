//
//  LocationSearchTable.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 12/30/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreLocation
import SystemConfiguration

class LocationSearchTable2: UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch2? = nil
    let fh = ManagedObject()
    let locationManager = CLLocationManager()
    let defaults = UserDefaults()
    var locationAlertView: LocationAlertView!
    let placeViewController = PlaceViewController()
    var selectedItem:MKPlacemark!
    var id = Int()
    var region:CLCircularRegion!
    var placeMark:CLPlacemark!
    var p:MKPlacemark?
    var mKI = MKMapItem()
    var location = CLLocation()
    let geoCoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInternetAvailable() {
            self.location = CLLocation(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler:{ (placemarks, error) -> Void in
                self.placeMark = (placemarks?[0])
                self.p = MKPlacemark(placemark: self.placeMark)})
        }
        else {
            let myVC = storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
            let alert = UIAlertController(title: "Warning", message: "You do not have an internet connection right now. Therefore, we can not search for locations. Please connect to the internet and try again!", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.pushViewController(myVC, animated: true)
                
            })
            alert.addAction(alertAction)
            self.present(alert, animated: true)
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if isInternetAvailable() {
            self.location = CLLocation(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler:{ (placemarks, error) -> Void in
                self.placeMark = (placemarks?[0])
                self.p = MKPlacemark(placemark: self.placeMark)})
        }
        else {
            let myVC = storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
            let alert = UIAlertController(title: "Warning", message: "You do not have an internet connection right now. Therefore, we can not search for locations. Please connect to the internet and try again!", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.pushViewController(myVC, animated: true)
                
            })
            alert.addAction(alertAction)
            self.present(alert, animated: true)
            
        }
        
    }
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.subLocality ?? "",
            comma,
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}
extension LocationSearchTable2 : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.dataSource = self
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text  else { return }
        searchController.searchBar.keyboardAppearance = .dark
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
extension LocationSearchTable2 {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  1 + self.matchingItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapSearchCell2", for: indexPath)
        if indexPath.row == 0 {
            let rect = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height))
            cell.addSubview(rect)
            rect.text = "Current Location"
            rect.textColor = UIColor.green
            cell.backgroundColor = UIColor.black
            rect.textAlignment = .center
            rect.font = UIFont(name: "EuphemiaUCAS-Italic", size: 35)!
            cell.textLabel?.isHidden = true
            cell.detailTextLabel?.isHidden = true
        }
        else {
            cell.textLabel?.font = UIFont(name: "EuphemiaUCAS-Italic", size: 15)!
            cell.textLabel?.textColor = UIColor.blue
            let selectedItem = self.matchingItems[indexPath.row - 1].placemark
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        }
        return cell
    }
}
extension LocationSearchTable2 {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedItem = p
        }
        else {
            selectedItem = matchingItems[indexPath.row - 1].placemark
        }
    
        // drop pin and dismiss table view controller
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}

