import Flutter
import UIKit
import ZendeskSDK
import ZendeskSDKMessaging

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    
    private var zendeskMessaging: ZendeskMessaging
    private var zendeskMessagingNotificationDelegate: ZendeskMessagingNotificationDelegate
    private var unreadMessageCountStreamHandler: UnreadMessageCountStreamHandler
    
    private let zendeskMessagingPluginChannelName: String = "zendesk_messaging"
    private let zendeskUnreadMessageCountStreamChannelName: String = "zendesk_messaging/unread_message_count_change"
    
    public override init() {
        zendeskMessagingNotificationDelegate = ZendeskMessagingNotificationDelegate()
        unreadMessageCountStreamHandler = UnreadMessageCountStreamHandler()
        zendeskMessaging = ZendeskMessaging(unreadMessageCountStreamHandler)
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
