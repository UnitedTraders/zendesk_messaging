package com.unitedtraders.mobile.zendesk_messaging

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ZendeskMessagingPlugin */
class ZendeskMessagingPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var unreadMessageCountEventChannel: EventChannel
    private lateinit var urlToHandleInAppEventChannel: EventChannel
    private lateinit var unreadMessageCountChangeStreamHandler: UnreadMessageCountChangeStreamHandler
    private lateinit var urlToHandleInAppStreamHandler: UrlToHandleInAppStreamHandler
    private lateinit var zendeskMessaging: ZendeskMessaging

    private var zendeskUnreadMessageCountStreamChannelName =
        "zendesk_messaging/unread_message_count_change"
    private var zendeskUrlToHandleInAppStreamChannelName = "zendesk_messaging/url_to_handle_in_app"
    private var zendeskMessagingChannelName = "zendesk_messaging"

    var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, zendeskMessagingChannelName)
        unreadMessageCountEventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            zendeskUnreadMessageCountStreamChannelName,
        )
        urlToHandleInAppEventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            zendeskUrlToHandleInAppStreamChannelName,
        )

        unreadMessageCountChangeStreamHandler = UnreadMessageCountChangeStreamHandler()
        urlToHandleInAppStreamHandler = UrlToHandleInAppStreamHandler()

        unreadMessageCountEventChannel.setStreamHandler(unreadMessageCountChangeStreamHandler)
        urlToHandleInAppEventChannel.setStreamHandler(urlToHandleInAppStreamHandler)

        zendeskMessaging = ZendeskMessaging(unreadMessageCountChangeStreamHandler, urlToHandleInAppStreamHandler)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        unreadMessageCountEventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            Constants.InitializeCommand -> zendeskMessaging.initializeZendesk(
                call,
                result,
                activity!!
            )
            Constants.LoginCommand -> zendeskMessaging.loginUser(call, result)
            Constants.LogoutCommand -> zendeskMessaging.logoutUser(result)
            Constants.ShowViewCommand -> zendeskMessaging.showZendesk(result, activity!!)
            else -> result.notImplemented()
        }
    }
}
