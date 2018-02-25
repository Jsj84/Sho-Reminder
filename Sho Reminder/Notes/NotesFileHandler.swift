
import Foundation
import CoreData
import UIKit

class NotesFileHandler: NSObject{
    
      var noteObject:[NSManagedObject] = []
    
//    func getDocumentsDirectory() -> NSString {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentsDirectory = paths[0]
//        return documentsDirectory as NSString
//    }
//
    
    func saveNotes(title: String, body: String, id: Int, date: Date) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Notes", in: getContext())!
        
        let object = NSManagedObject(entity: entity, insertInto: getContext())
        
        object.setValue(title, forKeyPath: "title")
        object.setValue(body, forKey: "body")
        object.setValue(id, forKey: "id")
        object.setValue(date, forKey: "date")
        
        do {
            try getContext().save()
            noteObject.append(object)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getNotes() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
        
        do {
            noteObject = try getContext().fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func updateNotes(title: String, body: String, id: Int, date: Date) {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Notes")
        let predicate = NSPredicate(format: "id = '\(id)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try getContext().fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(title, forKey: "title")
                objectUpdate.setValue(body, forKey: "body")
                objectUpdate.setValue(date, forKey: "date")
                do{
                    try getContext().save()
                    getNotes()
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
    }
//    func saveNotes(data: NSMutableArray){
//        let file = getDocumentsDirectory().appendingPathComponent("notes.txt")
//        if fileExists(file: file){
//            deleteFile(file: file)
//        }
//
//        var temp = ""
//        for i in 0 ..< data.count {
//                let d = data[i] as! Note
//               temp = temp.appending(d.toString())
//        }
//        do { try temp.data(using: String.Encoding.utf8)!.write(to: databaseURL()!)}
//        catch {
//            print("\(error)")
//        }
//    }
//
//    func getNotes() -> NSMutableArray {
//        let file = getDocumentsDirectory().appendingPathComponent("notes.txt")
//        let array = NSMutableArray()
//        if fileExists(file: file){
//            do {
//              let fileString = try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue) as String
//                let notesArray = fileString.components(separatedBy: "END_NOTE")
//                for i in 0 ..< notesArray.count {
//                    if  notesArray[i].count > 0 {
//                        let tempArray = notesArray[i].components(separatedBy: "\t")
//                        let tempNote = Note()
//                        tempNote.id = Int(tempArray[0])!
//                        tempNote.title = tempArray[1]
//                        tempNote.content = tempArray[2]
//                        array.add(tempNote)
//                    }
//                }
//            } catch {
//
//            }
//        }
//        return array
//    }
//
//    func fileExists(file: String)-> Bool{
//        return FileManager.default.fileExists(atPath: file)
//    }
//
//    func deleteFile(file: String) {
//        do {
//            try FileManager.default.removeItem(atPath: file)
//        } catch {
//
//        }
//    }
//    func databaseURL() -> URL? {
//
//        let fileManager = FileManager.default
//
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//
//         let documentDirectory:NSURL = urls.first! as NSURL
//
//            // This is where the database should be in the documents directory
//            let finalDatabaseURL = documentDirectory.appendingPathComponent("notes.txt")
//
//            if (finalDatabaseURL != nil) {
//                // The file already exists, so just return the URL
//                return finalDatabaseURL! as URL
//            } else {
//                // Copy the initial file from the application bundle to the documents directory
//                if let bundleURL = Bundle.main.url(forResource: "notes", withExtension: "txt") {
//
//                    do {
//                        try fileManager.copyItem(at: bundleURL, to: finalDatabaseURL!)
//                    } catch let error as NSError  {// Handle the error
//                        print("Couldn't copy file to final location! Error:\(error)")
//                    }
//
//                } else {
//                    print("Couldn't find initial database in the bundle!")
//                }
//            }
//        return nil
//    }
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
