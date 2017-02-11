//
//  AppDelegate.swift
//  Sho Remind
//
//  Created by Jesse St. John on 12/24/16.
//  Copyright © 2016 JNJ Apps. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var isGrantedNotificationAccess:Bool = false
    let locationManager = CLLocationManager()
    let fh = ManagedObject()
    let d = TimeAddViewController()
    var defaults = UserDefaults()
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        fh.getLocationData()
        if fh.locationObject.isEmpty == true {
            locationManager.stopUpdatingLocation()
        }
        else {
            locationManager.startUpdatingLocation()
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func intervalNotification(date: Date, title: String, body: String, identifier: String, theInterval: String) {
        
        var interval = TimeInterval()
        let calendar = Calendar.current
        
        switch theInterval {
        case "Hourly":
            interval = TimeInterval(NSCalendar.Unit.hour.rawValue)
        case "Daily":
            interval = TimeInterval(NSCalendar.Unit.day.rawValue)
            break
        case "Weekly":
            interval = TimeInterval(NSCalendar.Unit.day.rawValue) * 7
            break
        case "Monthly":
            interval = TimeInterval(NSCalendar.Unit.month.rawValue)
            break
        case "Yearly":
            interval = TimeInterval(NSCalendar.Unit.year.rawValue)
        default:
            interval = TimeInterval(NSCalendar.Unit.second.rawValue) * 60
            break
        }
        let component = calendar.dateComponents([.hour, .second, .minute, .day, .year, .month], from: date.addingTimeInterval(interval))
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: component, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    func locationNotification(title: String, body: String, identifer: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let content = UNMutableNotificationContent()
        content.body = body
        content.title = title
        content.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: identifer, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    func deleteNotification(identifier: String) {
        let identifier = identifier
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print(identifier)
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Sho_Reminder")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

