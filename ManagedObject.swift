//
//  ManagedObject.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/27/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ManagedObject: NSObject {
    
    var context: NSManagedObjectContext
    var names:[NSObject] = []
    var date:[NSObject] = []
    var i = 0
    
    
    override init() {
        
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "Sho_Reminder", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let myfatalError = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: myfatalError)
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex - 1]
            let storURL = docURL.appendingPathComponent("Sho_Reminder.sqlite")
            
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    func writeData (Items: String, name: String, date: String) {
        let context = self.context
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "Items", in: context)
        
        let transc = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        transc.setValue(name, forKey: "name")
        transc.setValue(date, forKey: "date")
        
        //save the object
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    func getData () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Items> = Items.fetchRequest()
        
        do {
            //go get the results
            let searchResults = try context.fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in (searchResults as [NSManagedObject]!) {
                //get the Key Value pairs (although there may be a better way to do that...
                names.append(trans.value(forKey: "name") as! NSObject)
                date.append(trans.value(forKey: "date") as! NSObject)
                
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    func deleteRecords(name: Int, date: Int){
        let moc = self.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        
        let result = try? moc.fetch(fetchRequest)
        let resultData = result as! [Items]

        for _ in resultData {
           let object = resultData.first
            moc.delete(object!)
            print("Inex Deleted: \(object)")
        }
//        
//        let object = resultData.first
//                moc.delete(object!)
//            print(object!)
    
        do {
            try moc.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    // MARK: Get Context
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
