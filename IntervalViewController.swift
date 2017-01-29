//
//  IntervalViewController.swift
//  Sho Reminder
//
//  Created by Jesse St. John on 1/26/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit

class IntervalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: setRepeat?
    
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = ["Hourly", "Daily", "Weekly", "Monthly", "Yearly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = dataSource[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let cellText = tableView.cellForRow(at: indexPath)?.textLabel?.text
        delegate?.repeatIs(interval: cellText!)
        self.dismiss(animated: true, completion: nil)
  }
}
