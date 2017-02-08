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
        
        var allow = Bool()
        var interval = TimeInterval()
        
        switch theInterval {
        case "Hourly":
            allow = true
            interval = 60
        case "Daily":
            allow = true
            interval = TimeInterval(60 * 24)
            break
        case "Weekly":
            allow = true
            interval = TimeInterval(60 * 24 * 7)
            break
        case "Monthly":
            allow = true
            interval = TimeInterval(60 * 24 * 7)
            break
        case "Yearly":
            allow = true
            interval = 60
        default:
            allow = false
            interval = 60
            break
        }
        let someMinutesEarlier = Calendar.current.date(byAdding: .second, value: Int(interval), to: date)
        let testinterval = someMinutesEarlier?.timeIntervalSinceNow

       // let notificationTime = date.addingTimeInterval(interval)
       // let components = Calendar.current.dateComponents([.second], from: notificationTime)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: testinterval!, repeats: allow)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    func scheduleNotification(atDate: Date, body: String, title: String, identifier: String) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: atDate)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
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

