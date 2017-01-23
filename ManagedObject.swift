//
//  ManagedObject.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/27/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Foundation

class ManagedObject: NSObject {
    
    var context: NSManagedObjectContext
    
    var timeObject: [NSManagedObject] = []
    var locationObject:[NSManagedObject] = []
    var location : String = ""
    var theLocation = CLLocation()
    var places:[NSManagedObject] = []
    
    
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
    
    func save(name: String, date: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Items", in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(name, forKeyPath: "name")
        object.setValue(date, forKey: "dateString")
        
        do {
            try managedContext.save()
            timeObject.append(object)
            
            print("your query has been saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
        func getData() {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Items")
            
            do {
                timeObject = try managedContext.fetch(fetchRequest)
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    
    func writeLocationData (latitude: Double, longitude: Double, mKtitle: String, mKSubTitle: String, reminderInput: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Locations", in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        
        object.setValue(latitude, forKeyPath: "latitude")
        object.setValue(longitude, forKey: "longitude")
        object.setValue(mKtitle, forKey: "mKtitle")
        object.setValue(mKSubTitle, forKey: "mKSubTitle")
        object.setValue(reminderInput, forKey: "reminderInput")
        
        do {
            try managedContext.save()
            locationObject.append(object)
            print("your query has been saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func getLocationData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let locationRequest = NSFetchRequest<NSManagedObject>(entityName: "Locations")
        
        do {
            locationObject = try managedContext.fetch(locationRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
// MARK: Get Context
func getContext () -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}
