package com.unitedtraders.mobile.zendesk_messaging

import io.flutter.plugin.common.EventChannel

class UrlToHandleInAppStreamHandler: EventChannel.StreamHandler {
    private var eventsSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventsSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventsSink = null
    }

    fun onUrlToHandleInAppEvent(urlToHandle: String) {
        eventsSink?.success(urlToHandle)
    }
}