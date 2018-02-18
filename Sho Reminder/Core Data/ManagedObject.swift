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

    func save(name: String, dateString: String, date: Date, repeatOption: String, id: Int) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Items", in: getContext())!
        
        let object = NSManagedObject(entity: entity, insertInto: getContext())
        
        object.setValue(name, forKeyPath: "name")
        object.setValue(dateString, forKey: "dateString")
        object.setValue(date, forKey: "date")
        object.setValue(repeatOption, forKey: "repeatOption")
        object.setValue(id, forKey: "id")
        
        do {
            try getContext().save()
            timeObject.append(object)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func getData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Items")
        
        do {
            timeObject = try getContext().fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func writeLocationData (latitude: Double, longitude: Double, mKtitle: String, mKSubTitle: String, reminderInput: String, id: Int, entrance: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Locations", in: getContext())!
        let object = NSManagedObject(entity: entity, insertInto: getContext())
        
        object.setValue(latitude, forKeyPath: "latitude")
        object.setValue(longitude, forKey: "longitude")
        object.setValue(mKtitle, forKey: "mKtitle")
        object.setValue(mKSubTitle, forKey: "mKSubTitle")
        object.setValue(reminderInput, forKey: "reminderInput")
        object.setValue(id, forKey: "id")
        object.setValue(entrance, forKey: "entrance")
        
        do {
            try getContext().save()
            locationObject.append(object)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func getLocationData() {
        
        let locationRequest = NSFetchRequest<NSManagedObject>(entityName: "Locations")
        
        do {
            locationObject = try getContext().fetch(locationRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func updateTimeData(name: String, dateString: String, date: Date, repeatOption: String, id: Int, index: Int) {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Items")
        let predicate = NSPredicate(format: "id = '\(id)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try getContext().fetch(fetchRequest)
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
                    try getContext().save()
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
    func updateLocation(entrance: String, lat: Double, lng: Double, title: String, subtitle: String, id: Int, reminderInput: String) {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Locations")
        let predicate = NSPredicate(format: "id = '\(id)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try getContext().fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(entrance, forKey: "entrance")
                objectUpdate.setValue(lat, forKey: "latitude")
                objectUpdate.setValue(lng, forKey: "longitude")
                objectUpdate.setValue(title, forKey: "mKtitle")
                objectUpdate.setValue(subtitle, forKey: "mKSubTitle")
                objectUpdate.setValue(id, forKey: "id")
                objectUpdate.setValue(reminderInput, forKey: "reminderInput")
                do{
                    try getContext().save()
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

    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
