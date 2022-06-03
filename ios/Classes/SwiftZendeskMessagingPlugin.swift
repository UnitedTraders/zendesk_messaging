import Flutter
import UIKit
import ZendeskSDK
import ZendeskSDKMessaging

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    
    private var zendeskMessaging: ZendeskMessaging
    private var unreadMessageCountStreamHandler: UnreadMessageCountStreamHandler
    
    private let zendeskMessagingPluginChannelName: String = "zendesk_messaging"
    private let zendeskUnreadMessageCountStreamChannelName: String = "zendesk_messaging/unread_message_count_change"
    
    public override init() {
        unreadMessageCountStreamHandler = UnreadMessageCountStreamHandler()
        zendeskMessaging = ZendeskMessaging(unreadMessageCountStreamHandler)
        
        super.init()
        initializeNotifications()
    }
        
    public static func register(with registrar: FlutterPluginRegistrar) {
        let pluginInstance = SwiftZendeskMessagingPlugin()
        let channel = FlutterMethodChannel(name: "zendesk_messaging", binaryMessenger:       registrar.messenger())
        let streamChannel = FlutterEventChannel(name: "zendesk_messaging/unread_message_count_change", binaryMessenger: registrar.messenger())
        
        registrar.addMethodCallDelegate(pluginInstance, channel: channel)
        streamChannel.setStreamHandler(pluginInstance.unreadMessageCountStreamHandler)
        
        registrar.addApplicationDelegate(pluginInstance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case Constants.InitializeCommand:
            zendeskMessaging.initialize(call: call, flutterResult: result)
        case Constants.LoginCommand:
            zendeskMessaging.loginUser(call: call, flutterResult: result)
        case Constants.LogoutCommand:
            zendeskMessaging.logoutUser(call: call, flutterResult: result)
        case Constants.ShowViewCommand:
            zendeskMessaging.showZendesk(call: call, flutterResult: result)
        default:
            result(ErrorUtils.buildError(title: Constants.IncorrectCommand))
        }
    }
}

extension SwiftZendeskMessagingPlugin {
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotifications.updatePushNotificationToken(deviceToken)
    }
}

extension SwiftZendeskMessagingPlugin: UNUserNotificationCenterDelegate {
    private func initializeNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        NotificationPermissionsHandler.silentlyAskForPermissions(notificationCenter)
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
                guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
                    return
                }
                
                guard let nonNullableViewController = viewController else {
                    return
                }
                
                rootViewController.present(nonNullableViewController, animated: true)
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
