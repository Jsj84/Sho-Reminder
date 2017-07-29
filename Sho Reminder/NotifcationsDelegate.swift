//
//  NotifcationsDelegate.swift
//  Sho Reminder
//
//  Created by Jesse on 7/29/17.
//  Copyright © 2017 JNJ Apps. All rights reserved.
//

import Foundation
import NotificationCenter
import UserNotifications

class NotifcationsDelegate: NSObject, UNUserNotificationCenterDelegate {
    

func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                completionHandler()
    }
}
