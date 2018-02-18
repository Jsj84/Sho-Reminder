//
//  NoteDetailViewController.swift
//  ATS
//
//  Created by Jesse St. John on 4/9/16.
//  Copyright © 2016 CDS (Consolidated Data Services). All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {
    
    var note: Note!
    var notes: NSMutableArray!
    let fh = NotesFileHandler()
    
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var contentTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationItem.backBarButtonItem = backButton
        
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        titleTextField.backgroundColor = UIColor.white
        titleTextField.layer.cornerRadius = 8
        contentTextField.backgroundColor = UIColor.white
        contentTextField.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.text = note.title
        contentTextField.text = note.content
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        note.title = titleTextField.text
        note.content = contentTextField.text
        
        if titleTextField.text != "" || contentTextField.text != "" {
            
            fh.saveNotes(data: notes)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
