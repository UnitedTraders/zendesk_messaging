//
//  ZendeskMessagingNotifications.swift
//  zendesk_messaging
//
//  Created by Aleksey Shepelev on 22.05.2022.
//

import Foundation
import ZendeskSDKMessaging

public class ZendeskMessagingNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    public override init() {
        super.init()
        initializeNotifications()
    }
    
    private func initializeNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        notificationCenter.getNotificationSettings {
            settings in
            if (settings.authorizationStatus == .authorized) {
                self.getDeviceTokenIfNotificationsAreEnabled(notificationCenter)
            } else if #available(iOS 12.0, *){
                if (settings.authorizationStatus == .provisional){
                    self.getDeviceTokenIfNotificationsAreEnabled(notificationCenter)
                }
            }
        }
    }
    
    private func getDeviceTokenIfNotificationsAreEnabled(_ notificationCenter: UNUserNotificationCenter) {
        notificationCenter.requestAuthorization {
            allowed, _ in
            guard allowed else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        let shouldBeDisplayed = PushNotifications.shouldBeDisplayed(userInfo)

        switch shouldBeDisplayed {
        case .messagingShouldDisplay:
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound, .badge])
            } else {
                completionHandler([.alert, .sound, .badge])
            }
        case .messagingShouldNotDisplay:
            completionHandler([])
        case .notFromMessaging:
            completionHandler([])
        @unknown default: break
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        let shouldBeDisplayed = PushNotifications.shouldBeDisplayed(userInfo)

        switch shouldBeDisplayed {
        case .messagingShouldDisplay:
            PushNotifications.handleTap(userInfo) { viewController in
                
        }
        case .messagingShouldNotDisplay:
            break
        case .notFromMessaging:
            break
        @unknown default: break
        }

        completionHandler()
    }
}
