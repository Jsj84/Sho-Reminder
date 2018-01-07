//
//  NotesListTableViewController.swift
//  ATS
//
//  Created by Jesse St. John on 4/9/16.
//  Copyright © 2016 CDS (Consolidated Data Services). All rights reserved.
//

import UIKit

class NotesListTableViewController: UITableViewController {
    
    @IBAction func AddNote(_ sender: Any) {
        performSegue(withIdentifier: "addNote", sender: self)
    }
    
    var notes = NSMutableArray()
    let fh = NotesFileHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.notes = fh.getNotes()
//        print(notes)
        // download notes before reloading data
        
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell")
        cell?.textLabel!.text = (notes[indexPath.row] as! Note).title
        return cell!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showNote" {
            let noteDetailViewController = segue.destination as! NoteDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            noteDetailViewController.note = notes.object(at: selectedIndexPath!.row) as! Note
            noteDetailViewController.notes = notes
        } else if segue.identifier! == "addNote" {
            let note = Note()
            notes.add(note)
            let noteDetailViewController = segue.destination as! NoteDetailViewController
            noteDetailViewController.note = note
            noteDetailViewController.notes = notes
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: "showNote", sender: self)
    }
    // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        notes.removeObject(at: indexPath.row)
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        fh.saveNotes(notes)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
}
