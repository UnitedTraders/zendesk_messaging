//
//  NotificationPermissionsHandler.swift
//  zendesk_messaging
//
//  Created by Aleksey Shepelev on 03.06.2022.
//

import Foundation

class NotificationPermissionsHandler {
    static func silentlyAskForPermissions(_ notificationCenter: UNUserNotificationCenter) {
        notificationCenter.getNotificationSettings {
            settings in
            if (settings.authorizationStatus == .authorized) {
                askForPermissions(notificationCenter)
            } else if #available(iOS 12.0, *){
                if (settings.authorizationStatus == .provisional){
                    askForPermissions(notificationCenter)
                }
            }
        }
    }
    
    static func askForPermissionsIfNotDenied(_ notificationCenter: UNUserNotificationCenter) {
        notificationCenter.getNotificationSettings {
            settings in
            if (settings.authorizationStatus != .denied) {
                askForPermissions(notificationCenter)
            }
        }
    }
    
    private static func askForPermissions(_ notificationCenter: UNUserNotificationCenter) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            allowed, _ in
            guard allowed else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
