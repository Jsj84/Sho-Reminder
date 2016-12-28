//
//  TimeViewController.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/25/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TimeViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var reminderName: UILabel!
    @IBOutlet weak var reminderDiscription: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var textEntered:[String] = []
    var t:NSMutableArray = NSMutableArray()

    var context: NSManagedObjectContext?{
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTranscriptions()
        
        timePicker.backgroundColor = UIColor.black
        timePicker.layer.cornerRadius = 10
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        view.backgroundColor = UIColor.clear
        
        
        reminderDiscription.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.isOpaque = true
        tableView.allowsSelection = false
        reminderDiscription.returnKeyType = UIReturnKeyType.done
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
        tableView.reloadData()
        
    }
    func storeTranscription (Items: String, name: String) {
        let context = self.context
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "Items", in: context!)
        
        let transc = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        transc.setValue(name, forKey: "name")
        textEntered = [name]
        
        //save the object
        do {
            try context?.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    func getTranscriptions () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Items> = Items.fetchRequest()
        
        do {
            //go get the results
            let searchResults = try context?.fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults?.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in (searchResults as [NSManagedObject]!) {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(trans.value(forKey: "name"))")

            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if reminderDiscription.text?.isEmpty == true {
            let alert = UIAlertController(title: "Alert", message: "You cannot save this reminder without a discription", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK, Got it!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.view.endEditing(true)
            storeTranscription(Items: "Items", name: textField.text!)
            getTranscriptions()
            reminderDiscription.text?.removeAll()
            
          //  let dateOnPicker = timePicker.date //capture the date shown on the picker
//            let dateFormatter = DateFormatter() //create a date formatter
//            
//            dateFormatter.dateStyle = DateFormatter.Style.short
//            dateFormatter.timeStyle = DateFormatter.Style.short
            
         //   let timeString = dateFormatter.string(from: dateOnPicker)
            tableView.reloadData()
        }
        return false
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saved Reminders"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textEntered.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimeTableViewCell
        cell.myLabel_1.text = textEntered[indexPath.row]
      //  cell.myLabel_2.text = timeAsString[row]
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = 5
        cell.layer.cornerRadius = 15
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            textEntered.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
