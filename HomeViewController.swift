//
//  ViewController.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/24/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fh = ManagedObject()
    var color = UIColor(netHex:0x90F7A3)
    
    var timeObject:[NSManagedObject] = []
    var locationObject:[NSManagedObject] = []
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SectionTwoCell.self, forCellReuseIdentifier: "cell")
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.green
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        way.font = UIFont (name: "HelveticaNeue-Bold", size: 19)!
        
        place.layer.cornerRadius = 8
        place.backgroundColor = color
        place.titleLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 18)!
        place.setTitle("Place", for: .normal)
        
        time.layer.cornerRadius = 8
        time.backgroundColor = color
        time.titleLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 18)!
        time.setTitle("Time", for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = color
        tableView.backgroundView?.isOpaque = true
        tableView.allowsSelection = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Items")
        let locationRequest = NSFetchRequest<NSManagedObject>(entityName: "Locations")
        
        do {
            timeObject = try managedContext.fetch(fetchRequest)
            locationObject = try managedContext.fetch(locationRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if timeObject.isEmpty == true {
                return "You do not have any upcoming reminders"
            }
            else if timeObject.count == 1 {
                return "You have 1 reminder scheduled"
            }
            else if timeObject.count < 3 {
                return "You have " + "\(timeObject.count)" + " reminders scheduled"
            }
            else {
                return "Your next 3 reminders are"
            }
        }
        else if section == 1 {
        }
        return "Next location reminder"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        else  {
            return 55
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return timeObject.count
        }
        else {
            return locationObject.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeTableViewCell
            cell.myLabel_1.text = timeObject[indexPath.row].value(forKey: "name") as! String?
            cell.myLabel_2.text = timeObject[indexPath.row ].value(forKey: "dateString") as! String?
            cell.backgroundColor = UIColor.clear
            return cell
        }
            else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SectionTwoCell
            cell.nameLable.text = locationObject[indexPath.row].value(forKey: "mKtitle") as! String?
            cell.subtitleLable.text = locationObject[indexPath.row].value(forKey: "mKSubTitle") as! String?
            cell.backgroundColor = UIColor.clear
            return cell
        }
    }
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
