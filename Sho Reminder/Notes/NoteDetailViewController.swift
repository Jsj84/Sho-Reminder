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
    var cancelButtonTitle = ""
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var contentTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let canelButton = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(cancelPop))
        canelButton.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem = canelButton
        
        
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
    @objc func cancelPop() {
        self.titleTextField.text = ""
        self.contentTextField.text = ""
        self.navigationController?.popViewController(animated: true)
    }
}
