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
    
    let dataSource = ["Hourly", "Daily", "Weekly", "Monthly", "Yearly"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        return cell!
    }
}
