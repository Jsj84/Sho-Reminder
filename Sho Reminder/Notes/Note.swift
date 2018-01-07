//
//  Note.swift
//  ATS
//
//  Created by Jesse St. John on 4/9/16.
//  Copyright © 2016 CDS (Consolidated Data Services). All rights reserved.
//

import Foundation

class Note {
    
    var id = -1
    var title = ""
    var content = ""
    
    func toString() -> String {
        return String(id).appending("\t").appending(title).appending("\t").appending(content).appending("END_NOTE")
//        String(id).stringByAppendingString("\t").stringByAppendingString(title).stringByAppendingString("\t").stringByAppendingString(content).stringByAppendingString("END_NOTE");
    }
    
}
