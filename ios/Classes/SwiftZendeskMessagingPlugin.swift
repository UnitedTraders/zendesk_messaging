import Flutter
import UIKit
import ZendeskSDK
import ZendeskSDKMessaging

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    private var zendeskMessaging: ZendeskMessaging
    
    public override init() {
        zendeskMessaging = ZendeskMessaging()
    }
        
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_messaging", binaryMessenger:       registrar.messenger())
        let instance = SwiftZendeskMessagingPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
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
