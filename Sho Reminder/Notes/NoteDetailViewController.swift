//
//  NoteDetailViewController.swift
//  ATS
//
//  Created by Jesse St. John on 4/9/16.
//  Copyright © 2016 CDS (Consolidated Data Services). All rights reserved.
//

import UIKit
import CoreData

class NoteDetailViewController: UIViewController, UITextViewDelegate {
    
    let fh = NotesFileHandler()
    var cancelButtonTitle = ""
    var tempTitle = ""
    var tempBody = ""
    var IDHolder = 0
    let defaults = UserDefaults()
    var newNote = Bool()
    var placeholderLabel : UILabel!
    var datePassedThrough = Date()
    
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var contentTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let canelButton = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(cancelPop))
        canelButton.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem = canelButton
        
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        titleTextField.delegate = self
        titleTextField.backgroundColor = UIColor.white
        titleTextField.layer.cornerRadius = 8
        titleTextField.font = UIFont.boldSystemFont(ofSize: (titleTextField.font?.pointSize)!)
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Title.."
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (titleTextField.font?.pointSize)! + 5)
        placeholderLabel.sizeToFit()
        titleTextField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 15, y: (titleTextField.font?.pointSize)! / 2)
        placeholderLabel.layer.cornerRadius = 8
        placeholderLabel.textColor = UIColor.lightGray
    
        contentTextField.backgroundColor = UIColor.white
        contentTextField.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.text = tempTitle
        contentTextField.text = tempBody
        placeholderLabel.isHidden = !tempTitle.isEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var tempId = 0
        let date = Date()
        
        if (defaults.value(forKey: "noteObject") != nil) && (defaults.value(forKey: "noteObject") as! Int) != 0 {
            tempId = defaults.value(forKey: "noteObject") as! Int
        }
        if titleTextField.text != "" || contentTextField.text != "" {
            if newNote == false {
                fh.updateNotes(title: titleTextField.text, body: contentTextField.text, id: IDHolder, date: date)
            }
            else {
                fh.saveNotes(title: titleTextField.text, body: contentTextField.text, id: tempId, date: date)
                tempId = tempId + 1
                defaults.set(tempId, forKey: "noteObject")
            }
        }
}
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !titleTextField.text.isEmpty
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
