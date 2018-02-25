//
//  NotesListTableViewController.swift
//  ATS
//
//  Created by Jesse St. John on 4/9/16.
//  Copyright © 2016 CDS (Consolidated Data Services). All rights reserved.
//

import UIKit
import CoreData

class NotesListTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var color = UIColor(netHex:0x90F7A3)
    var resultSearchController:UISearchController!
    
    var filteredData:[String] = []
    
    var noteTitle:[String] = []
    var noteBody:[String] = []
    let fh = NotesFileHandler()

    
    @IBAction func AddNote(_ sender: Any) {
        performSegue(withIdentifier: "addNote", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fh.getNotes()
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = resultSearchController
        } else {
            self.tableView.tableHeaderView = resultSearchController.searchBar
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fh.getNotes()
        noteTitle.removeAll()
        noteBody.removeAll()
        
        for i in 0..<fh.noteObject.count {
            noteTitle.append(fh.noteObject[i].value(forKey: "title") as! String)
            noteBody.append(fh.noteObject[i].value(forKey: "body") as! String)
    
        }
              tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive {
            return filteredData.count
        }
        else {
            return fh.noteObject.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> NotesCellTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell") as! NotesCellTableViewCell
        if resultSearchController.isActive {
            cell.titleLabel?.text = filteredData[indexPath.row]
        }
        else {
            let d = (fh.noteObject[indexPath.row].value(forKey: "date") as! Date)
            let timestamp = DateFormatter.localizedString(from: d, dateStyle: .short, timeStyle: .short)
            
            let bod = (fh.noteObject[indexPath.row].value(forKey: "body") as! String)
            let trimmed = bod.replacingOccurrences(of: "\n", with: " ")
            
            cell.titleLabel.text = (fh.noteObject[indexPath.row].value(forKey: "title") as! String)
            cell.contentLabel.text = trimmed
            cell.dateModified.text = "Modified: " + timestamp
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let noteDetailViewController = segue.destination as! NoteDetailViewController
        
        let backItem = UIBarButtonItem()
        backItem.title = "Save"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier! == "showNote" {
            backItem.title = "Update"
            let selectedIndexPath = tableView.indexPathForSelectedRow
            noteDetailViewController.tempTitle = (fh.noteObject[selectedIndexPath!.row].value(forKey: "title") as! String)
            noteDetailViewController.tempBody = (fh.noteObject[selectedIndexPath!.row].value(forKey: "body") as! String)
            noteDetailViewController.IDHolder = (fh.noteObject[selectedIndexPath!.row].value(forKey: "id") as! Int)
            noteDetailViewController.datePassedThrough = (fh.noteObject[selectedIndexPath!.row].value(forKey: "date") as! Date)
            noteDetailViewController.newNote = false
            
        } else if segue.identifier! == "addNote" {
            noteDetailViewController.newNote = true
            noteDetailViewController.cancelButtonTitle = "Cancel"
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showNote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let managedContext = fh.getContext()
        managedContext.delete(self.fh.noteObject[indexPath.row] as NSManagedObject)
        self.fh.noteObject.remove(at: indexPath.row)
        do {
            try managedContext.save()
        }
        catch{
            print(" Sorry Jesse, had and error saving. The error is: \(error)")
        }
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.isActive {
            return ""
        }
        else {
            return "Notes"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerVew = view as? UITableViewHeaderFooterView {
            headerVew.backgroundView?.backgroundColor = UIColor.clear
            headerVew.textLabel?.textColor = UIColor.black
            headerVew.textLabel?.textAlignment = .left
            headerVew.textLabel?.font = UIFont (name: "HelveticaNeue-Bold", size: 20)!
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.searchBar.text!.count > 0 {
            filteredData.removeAll(keepingCapacity: false)
            let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", searchController.searchBar.text!)
          //  let k = (fh.noteObject as NSArray).filtered(using: searchPredicate) as NSArray
            
            let array = (noteTitle as NSArray).filtered(using: searchPredicate)
         
            filteredData = array as! [String]
            
        }
        else {
            filteredData.removeAll(keepingCapacity: false)
            filteredData = noteTitle
//            filteredData2.removeAll(keepingCapacity: false)
//            filteredData2 = noteBody
        }
        tableView.reloadData()
    }
}
