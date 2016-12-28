//
//  ViewController.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/24/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import UIKit
import Foundation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fh = ManagedObject()
    
    @IBOutlet weak var way: UILabel!
    @IBOutlet weak var place: UIButton!
    @IBOutlet weak var time: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func timeAction(_ sender: Any) {
        performSegue(withIdentifier: "timeSegue", sender: self)
    }
    @IBAction func placeAction(_ sender: Any) {
        performSegue(withIdentifier: "placeSegue", sender: self)
    }
    var sectionTwo:[String] = []
    let cellSpacingHeight: CGFloat = 20
    
    let tempString = ["10 Clinton St. Brooklyn, N.Y", "437 Madison Avenue, New Yory, N.Y", "Port Authority Bus Terminal"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.green
        view.backgroundColor = UIColor.clear
        
        way.font = UIFont (name: "HelveticaNeue-Bold", size: 19)!
        
        place.layer.cornerRadius = 8
        place.backgroundColor = UIColor.green
        place.titleLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 18)!
        place.setTitle("Place", for: .normal)
        
        time.layer.cornerRadius = 8
        time.backgroundColor = UIColor.green
        time.titleLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 18)!
        time.setTitle("Time", for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView?.isOpaque = true
        tableView.allowsSelection = false
        
        fh.getData()
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Next time reminder"
        }
        else {
            return "Next location reminder"
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fh.finalNames.count
        }
        else {
            return tempString.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeTableViewCell
            cell.myLabel_1.text = fh.finalNames[indexPath.row]
            //cell.myLabel_2.text = tempString[indexPath.row]
            cell.backgroundColor = UIColor.white
            cell.layer.borderWidth = 8
            cell.layer.cornerRadius = 15
            cell.layer.borderColor = UIColor.black.cgColor
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
            let row = indexPath.row
            cell?.textLabel?.text = tempString[row]
            cell?.backgroundColor = UIColor.white
            cell?.layer.borderWidth = 5
            cell?.layer.cornerRadius = 15
            cell?.layer.borderColor = UIColor.black.cgColor
            return cell!
        }
    }
}
