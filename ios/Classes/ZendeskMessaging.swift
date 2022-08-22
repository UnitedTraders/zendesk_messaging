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
    private var unreadMessageCountStreamHandler: UnreadMessageCountStreamHandler
    private var urlToHandleInAppStreamHandler: UrlToHandleInAppStreamHandler
    private var zendeskUiViewController: UIViewController?
    
    init(_ unreadMessageCountStreamHandler: UnreadMessageCountStreamHandler, _ urlToHandleInAppStreamHandler: UrlToHandleInAppStreamHandler) {
        self.unreadMessageCountStreamHandler = unreadMessageCountStreamHandler
        self.urlToHandleInAppStreamHandler = urlToHandleInAppStreamHandler
    }
    
    public func initialize(call: FlutterMethodCall, flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? Dictionary<String, NSObject> else {
            flutterResult(ErrorUtils.buildError(title: Constants.IncorrectArguments, details: Constants.InitializeArgumentsErrorDescription))
            return
        }
        
        guard let channelKey = arguments[Constants.ChannelKey] as? String else {
            flutterResult(ErrorUtils.buildError(title: Constants.IncorrectArguments, details: Constants.InitializeArgumentsErrorDescription))
            return
        }
        
        guard let shouldInterceptUrlHandling = arguments[Constants.ShouldInterceptUrlHandlingKey] as? Bool else {
            flutterResult(ErrorUtils.buildError(title: Constants.IncorrectArguments, details: Constants.InitializeArgumentsErrorDescription))
            return
        }
        
        Zendesk.initialize(withChannelKey: channelKey, messagingFactory: DefaultMessagingFactory(), completionHandler: { result in
            switch result {
            case .failure(let error):
                flutterResult(ErrorUtils.buildError(title: Constants.ZendeskInitializationFailureCode, details: error.localizedDescription))
            case .success(_):
                self.isInitialized = true
                self.addZendeskEventObserver(shouldInterceptUrlHandling)
                flutterResult(nil)
            }
        })
    }
    
    private func addZendeskEventObserver(_ shouldInterceptUrlHandling: Bool) {
        Zendesk.instance?.addEventObserver(self) { event in
            switch (event) {
            case .unreadMessageCountChanged(currentUnreadCount: let currentUnreadCount):
                self.unreadMessageCountStreamHandler.handleNewUnreadMessegeCount(currentUnreadCount)
                break
            case .authenticationFailed(error: _):
                break
            @unknown default:
                break
            }
        }
        
        if (shouldInterceptUrlHandling) {
            Messaging.delegate = self
        }
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
                NotificationPermissionsHandler.askForPermissionsIfNotDenied(UNUserNotificationCenter.current())
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
    
        guard let zendeskUiViewController = Zendesk.instance?.messaging?.messagingViewController() else {
            flutterResult(ErrorUtils.buildError(title: Constants.ZendeskShowViewFailureCode, details: "Failed to retreive zendesk messaging view controller"))
            return }
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            flutterResult(ErrorUtils.buildError(title: Constants.ZendeskShowViewFailureCode, details: "Failed to retrieve flutter root view controller"))
            return
        }
                
        for val in zendeskUiViewController.view.subviews {
            if(type(of: val) == UINavigationBar.self) {
                val.removeFromSuperview()
            }
        }
        
        zendeskUiViewController.view.addSubview(getCloseButton(zendeskUiViewController: zendeskUiViewController))
        rootViewController.present(zendeskUiViewController, animated: true, completion: nil)
        flutterResult(nil)
    }
    
    private func getCloseButton(zendeskUiViewController: UIViewController) -> UIButton {
        let closeButton = UIButton()
        
        closeButton.frame = CGRect(x: zendeskUiViewController.view.frame.size.width - 40, y: 20, width: 30, height: 30)
        closeButton.layer.cornerRadius = 15
        closeButton.setAttributedTitle(NSAttributedString(string: "×", attributes: [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 18) as Any, NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5)]), for: .normal)
        closeButton.contentVerticalAlignment = .center
        closeButton.contentHorizontalAlignment = .center
        closeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        closeButton.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = closeButton.bounds
        blurEffectView.isUserInteractionEnabled = false
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        closeButton.addSubview(blurEffectView)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.06)
        closeButton.addTarget(self, action: #selector(closeZendesk), for: .touchUpInside)
        
        return closeButton
    }
}

extension ZendeskMessaging : MessagingDelegate {
    func messaging(_ messaging: Messaging, shouldHandleURL url: URL, from source: URLSource) -> Bool {
        urlToHandleInAppStreamHandler.handleUrlToHandleInAppEvent(url.absoluteString)
        closeZendesk()
        
        return false
    }
    
    @objc private func closeZendesk() {
        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
    }
}




