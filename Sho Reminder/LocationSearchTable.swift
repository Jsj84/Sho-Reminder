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

class LocationSearchTable: UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    let fh = ManagedObject()
    let locationManager = CLLocationManager()
    let defaults = UserDefaults()
    
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
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}
extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.dataSource = self
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text  else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchingItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapSearchCell", for: indexPath)
        let selectedItem = self.matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}
extension LocationSearchTable {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id = Int()
        if defaults.value(forKey: "locationId") == nil {
            id = -1
        }
        else {
            id = defaults.value(forKey: "locationId") as! Int
        }
        print(id)
        let NsId = id as NSNumber
        let identifier = NsId.stringValue
        
        let selectedItem = matchingItems[indexPath.row].placemark
        
        let center = CLLocationCoordinate2D(latitude: selectedItem.coordinate.latitude, longitude: selectedItem.coordinate.longitude)
        let radius = 15 as CLLocationDistance
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        
        // drop pin and dismiss table view controller
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        
        // show aleart to gather information
        let alert = UIAlertController(title: "Location Reminder", message: "Enter the reminder for this location", preferredStyle: .alert)
        //2. Add the text field
        alert.addTextField { (textField) in
            textField.text = ""
            textField.autocorrectionType = .default
            textField.keyboardAppearance = .dark
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            // save to coreData
            self.fh.writeLocationData(latitude: selectedItem.coordinate.latitude, longitude: selectedItem.coordinate.longitude, mKtitle: selectedItem.name!, mKSubTitle: selectedItem.title!, reminderInput: (textField?.text!)!, id: id)
            self.locationManager.startMonitoring(for: region)
           let changedValue = id - 1
            self.defaults.set(changedValue, forKey: "locationId")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}
