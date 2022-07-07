//
//  UrlToHandleInAppStreamHandler.swift
//  zendesk_messaging
//
//  Created by Aleksey Shepelev on 05.07.2022.
//

import Foundation

class UrlToHandleInAppStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    func handleUrlToHandleInAppEvent(_ urlToHandle: String) {
        eventSink?(urlToHandle)
    }
}
