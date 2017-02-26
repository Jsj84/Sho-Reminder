//
//  TimeZoneViewController.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/27/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

class TimeZoneViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var color = UIColor(netHex:0x90F7A3)
    var defaults = UserDefaults()
    
    @IBAction func doCancel(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    let theZone = TimeZone.knownTimeZoneIdentifiers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Corkboard_BG"))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = color
    
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose a timezone"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return theZone.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = theZone[indexPath.row]
        return cell!
    }
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let zone = theZone[indexPath.row]
        defaults.set(zone, forKey: "timeZone")
        self.dismiss(animated: true, completion: nil)
    }
}
