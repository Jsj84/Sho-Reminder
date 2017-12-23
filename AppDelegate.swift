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
    let fh = ManagedObject()
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    let content = UNMutableNotificationContent()
    let defaults = UserDefaults()
    let notificationDelegate = NotifcationsDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        center.delegate = notificationDelegate
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        if defaults.value(forKey: "hasBeenOpen") == nil {
            center.removeAllDeliveredNotifications()
            center.removeAllPendingNotificationRequests()
            for monitored in locationManager.monitoredRegions {
                locationManager.stopMonitoring(for: monitored)
            }
            defaults.setValue("hasHad", forKey: "hasBeenOpen")
        }
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if fh.locationObject.count < 1 {
            locationManager.stopUpdatingLocation()
        }
        else {
            locationManager.startUpdatingLocation()
        }
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
        
        var components = DateComponents()
        let calendar = Calendar.current
        var YesOrNo = Bool()
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        switch theInterval {
        case "Hourly":
            YesOrNo = true; components = calendar.dateComponents([.minute, .second], from: date)
        case "Daily":
            YesOrNo = true; components = calendar.dateComponents([.hour, .minute, .second], from: date)
        case "Weekly":
            YesOrNo = true; components = calendar.dateComponents([.weekday, .hour, .minute, .second] , from: date)
        case "Monthly":
            YesOrNo = true; components = calendar.dateComponents([.day, .hour, .minute, .second], from: date)
        case "Yearly":
            YesOrNo = true; components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: date)
        default:
            YesOrNo = false; components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            break
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: YesOrNo)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let i = getObjectPath(region: region)
        let title = fh.locationObject[i].value(forKey: "mKtitle") as! String
        let body = fh.locationObject[i].value(forKey: "reminderInput") as! String
        let idInt = fh.locationObject[i].value(forKey: "id") as! Int
        let entranceType = fh.locationObject[i].value(forKey: "entrance") as! String
        let idNs = idInt as NSNumber
        let id = idNs.stringValue
        if entranceType == "onEnter" {
            content.title = "Entered: " + title
            content.body = body
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {(error) in
                if let error = error {
                    print("error: \(error)")
                }
            }
        }
        else {
            print("On exit notifcation only")
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let i = getObjectPath(region: region)
        let title = fh.locationObject[i].value(forKey: "mKtitle") as! String
        let body = fh.locationObject[i].value(forKey: "reminderInput") as! String
        let idInt = fh.locationObject[i].value(forKey: "id") as! Int
        let entranceType = fh.locationObject[i].value(forKey: "entrance") as! String
        let idNs = idInt as NSNumber
        let id = idNs.stringValue
        if entranceType == "onExit" {
            content.title = "Exited: " + title
            content.body = body
            content.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {(error) in
                if let error = error {
                    print("error: \(error)")
                }
            }
        }
        else {
          // print("On Enter Only")
        }
    }
    func getObjectPath(region: CLRegion) -> Int {
        var path = Int()
        fh.getLocationData()
        for i in 0..<fh.locationObject.count {
            let idInt = fh.locationObject[i].value(forKey: "id") as! Int
            let idNs = idInt as NSNumber
            let id = idNs.stringValue
            if id == region.identifier {
                path = i
            }
        }
        return path
    }
    func deleteNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
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
