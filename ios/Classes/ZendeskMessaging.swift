//
//  ZendeskMessaging.swift
//  zendesk_messaging
//
//  Created by Aleksey Shepelev on 22.03.2022.
//

import Foundation
import ZendeskSDK
import ZendeskSDKMessaging

class ZendeskMessaging {
    private var isInitialized: Bool = false
    
    public func initialize(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        guard let channelKey = call.arguments as? String else {
            flutterResult(ErrorUtils.buildError(title: Constants.IncorrectArguments, details: Constants.InitializeArgumentsErrorDescription))
            return
        }
        
        Zendesk.initialize(withChannelKey: channelKey, messagingFactory: DefaultMessagingFactory(), completionHandler: { result in
            switch result {
            case .failure(let error):
                flutterResult(ErrorUtils.buildError(title: Constants.ZendeskInitializationFailureCode, details: error.localizedDescription))
            case .success(_):
                self.isInitialized = true
                flutterResult(nil)
            }
        })
    }
    
    public func loginUser(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if !isInitialized {
            flutterResult(ErrorUtils.buildError(title: Constants.ZendeskLoginFailureCode, details: Constants.ZendeskNotInitializedDescription))
            return
        }
        
        guard let jwt = call.arguments as? String else {
            flutterResult(ErrorUtils.buildError(title: Constants.IncorrectArguments, details: Constants.LoginArgumentsErrorDescription))
            return
        }
        
        Zendesk.instance?.loginUser(with: jwt, completionHandler: {result in
            switch result {
            case .failure(let error):
                flutterResult(ErrorUtils.buildError(title: Constants.ZendeskLoginFailureCode, details: error.localizedDescription))
            case .success(let it):
                flutterResult([Constants.IdKey: it.id, Constants.ExternalIdKey: it.externalId])
            }
        })
    }
    
    public func logoutUser(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if !isInitialized {
            flutterResult(ErrorUtils.buildError(title: Constants.ZendeskLogoutFailureCode, details: Constants.ZendeskNotInitializedDescription))
            return
        }
        
        Zendesk.instance?.logoutUser(completionHandler: { result in
            switch result {
            case .failure(let error):
                flutterResult(ErrorUtils.buildError(title: Constants.ZendeskLogoutFailureCode, details: error.localizedDescription))
            case .success(_):
                flutterResult(nil)
            }
        })
    }
    
    public func showZendesk(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        if !isInitialized {
            flutterResult(ErrorUtils.buildError(title: Constants.ZendeskShowViewFailureCode, details: Constants.ZendeskNotInitializedDescription))
            return
        }
        
        guard let zendeskViewController = Zendesk.instance?.messaging?.messagingViewController() else {
            flutterResult(ErrorUtils.buildError(title: Constants.ZendeskShowViewFailureCode, details: "Failed to retreive zendesk messaging view controller"))
            return }
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            flutterResult(ErrorUtils.buildError(title: Constants.ZendeskShowViewFailureCode, details: "Failed to retrieve flutter root view controller"))
            return
        }
        
        rootViewController.present(zendeskViewController, animated: true, completion: nil)
        flutterResult(nil)
    }
}
