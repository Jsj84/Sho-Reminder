//
//  NotesListTableViewController.swift
//  ATS
//
//  Created by Jesse St. John on 4/9/16.
//  Copyright © 2016 CDS (Consolidated Data Services). All rights reserved.
//

import UIKit

class NotesListTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var color = UIColor(netHex:0x90F7A3)
    var resultSearchController:UISearchController!
    
    var filteredData:[String] = []
    var noteTitle:[String] = []
    var noteBody:[String] = []
    
    @IBAction func AddNote(_ sender: Any) {
        performSegue(withIdentifier: "addNote", sender: self)
    }
    
    var notes = NSMutableArray()
    let fh = NotesFileHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.notes = fh.getNotes()
        
        noteTitle.removeAll()
        noteBody.removeAll()
        
        for i in 0..<notes.count {
            noteTitle.append((notes[i] as! Note).title)
            noteBody.append((notes[i] as! Note).content)
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
            return notes.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> NotesCellTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell") as! NotesCellTableViewCell
        if resultSearchController.isActive {
            cell.titleLabel?.text = filteredData[indexPath.row]
        }
        else {
            cell.titleLabel.text = (notes[indexPath.row] as! Note).title
            cell.contentLabel.text = (notes[indexPath.row] as! Note).content
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let noteDetailViewController = segue.destination as! NoteDetailViewController
        
        let backItem = UIBarButtonItem()
        backItem.title = "Save"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier! == "showNote" {
            let selectedIndexPath = tableView.indexPathForSelectedRow
            noteDetailViewController.note = notes.object(at: selectedIndexPath!.row) as! Note
            noteDetailViewController.notes = notes
            
        } else if segue.identifier! == "addNote" {
            let note = Note()
            notes.add(note)
            noteDetailViewController.note = note
            noteDetailViewController.notes = notes
            noteDetailViewController.cancelButtonTitle = "Cancel"
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showNote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        notes.removeObject(at: indexPath.row)
        fh.saveNotes(data: notes)
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
            let array = (noteTitle as NSArray).filtered(using: searchPredicate)
            filteredData = array as! [String]
            tableView.reloadData()
            
        }
        else {
            filteredData.removeAll(keepingCapacity: false)
            filteredData = noteTitle
            tableView.reloadData()
        }
    }
}
