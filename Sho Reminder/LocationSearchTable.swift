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
    var locationAlertView: LocationAlertView!
    let placeViewController = PlaceViewController()
    var selectedItem:MKPlacemark!
    var id = Int()
    var region:CLCircularRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //cancel.addTarget(self, action: #selector(actionForbutton), for: .touchUpInside)
        //let enter:UIButton = locationAlertView.enter
        //locationAlertView.enter.addTarget(passDataDelegate, action: #selector(locationAlertView.okayButton), for: .touchUpInside)
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
        searchController.searchBar.keyboardAppearance = .dark
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
        if defaults.value(forKey: "locationId") == nil {
            id = -1
        }
        else {
            id = defaults.value(forKey: "locationId") as! Int
        }
        print(id)
        let NsId = id as NSNumber
        let identifier = NsId.stringValue
        
       selectedItem = matchingItems[indexPath.row].placemark
       
        let center = CLLocationCoordinate2D(latitude: selectedItem.coordinate.latitude, longitude: selectedItem.coordinate.longitude)
        let radius = 15 as CLLocationDistance
        region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        
        // drop pin and dismiss table view controller
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        
        dismiss(animated: true, completion: nil)
    }
}
