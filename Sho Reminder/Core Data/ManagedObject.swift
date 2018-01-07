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
    
    var timeObject: [NSManagedObject] = []
    var locationObject:[NSManagedObject] = []
   // var test:[NSManagedObject] = []
    
    override init() {
        
        var context:NSManagedObjectContext
        
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
    func save(name: String, dateString: String, date: Date, repeatOption: String, id: Int) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Items", in: managedContext)!
        
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(name, forKeyPath: "name")
        object.setValue(dateString, forKey: "dateString")
        object.setValue(date, forKey: "date")
        object.setValue(repeatOption, forKey: "repeatOption")
        object.setValue(id, forKey: "id")
        
        do {
            try managedContext.save()
            timeObject.append(object)
            
            print("your query has been saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func getData() {
        
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Items")
        
        do {
            timeObject = try managedContext.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func writeLocationData (latitude: Double, longitude: Double, mKtitle: String, mKSubTitle: String, reminderInput: String, id: Int, entrance: String) {
        
        let managedContext = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Locations", in: managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(latitude, forKeyPath: "latitude")
        object.setValue(longitude, forKey: "longitude")
        object.setValue(mKtitle, forKey: "mKtitle")
        object.setValue(mKSubTitle, forKey: "mKSubTitle")
        object.setValue(reminderInput, forKey: "reminderInput")
        object.setValue(id, forKey: "id")
        object.setValue(entrance, forKey: "entrance")
        
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

    func updateTimeData(name: String, dateString: String, date: Date, repeatOption: String, id: Int, index: Int) {
        let managedContext = getContext()
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Items")
        let predicate = NSPredicate(format: "id = '\(id)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                print(objectUpdate)
                objectUpdate.setValue(name, forKey: "name")
                objectUpdate.setValue(dateString, forKey: "dateString")
                objectUpdate.setValue(date, forKey: "date")
                 objectUpdate.setValue(repeatOption, forKey: "repeatOption")
                objectUpdate.setValue(id, forKey: "id")
                do{
                    try managedContext.save()
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
    func updateLocation(entrance: String, lat: Double, lng: Double, title: String, subtitle: String, id: Int, reminderInput: String, index: Int) {
        let managedContext = getContext()
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Locations")
        let predicate = NSPredicate(format: "id = '\(id)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                print(objectUpdate)
                objectUpdate.setValue(entrance, forKey: "entrance")
                objectUpdate.setValue(lat, forKey: "latitude")
                objectUpdate.setValue(lng, forKey: "longitude")
                objectUpdate.setValue(title, forKey: "mKtitle")
                objectUpdate.setValue(subtitle, forKey: "mKSubTitle")
                objectUpdate.setValue(id, forKey: "id")
                objectUpdate.setValue(reminderInput, forKey: "reminderInput")
                do{
                    try managedContext.save()
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
    func getById(id: NSManagedObjectID) -> Items? {
        let context = getContext()
        return context.object(with: id) as? Items
    }
    // MARK: Get Context
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
