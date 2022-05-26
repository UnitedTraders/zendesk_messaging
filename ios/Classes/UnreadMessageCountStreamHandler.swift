//
//  UnreadMessageCountStreamHandler.swift
//  zendesk_messaging
//
//  Created by Aleksey Shepelev on 18.05.2022.
//

import Foundation

class UnreadMessageCountStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    func handleNewUnreadMessegeCount(_ newCount: Int) {
        eventSink?(newCount)
    }
}
