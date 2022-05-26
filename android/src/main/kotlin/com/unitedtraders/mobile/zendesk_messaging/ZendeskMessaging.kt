package com.unitedtraders.mobile.zendesk_messaging

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import zendesk.android.Zendesk
import zendesk.android.events.ZendeskEvent
import zendesk.android.events.ZendeskEventListener
import zendesk.messaging.android.DefaultMessagingFactory

class ZendeskMessaging(private var unreadMessageCountChangeStreamHandler: UnreadMessageCountChangeStreamHandler) {
    private var isInitialized: Boolean = false
    private var isLoggedIn: Boolean = false

    fun initializeZendesk(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result, @NonNull activity: Activity) {
        val channelKey: String
        try {
            channelKey = call.arguments as String
        } catch (e: Exception) {
            result.error(Constants.IncorrectArguments, Constants.InitializeArgumentsErrorDescription, e.localizedMessage)
            return
        }

        Zendesk.initialize(
                activity,
                channelKey,
                successCallback = {
                    isInitialized = true
                    initializeZendeskEventListeners()
                    result.success(null)
                },
                failureCallback = {
                    result.error(Constants.ZendeskInitializationFailureCode, "Something went wrong on zendesk initializing stage", it.localizedMessage)
                },
                DefaultMessagingFactory(),
        )
    }

    private fun initializeZendeskEventListeners() {
        val zendeskListener = ZendeskEventListener {
            zendeskEvent: ZendeskEvent -> when (zendeskEvent) {
                is ZendeskEvent.UnreadMessageCountChanged -> {
                    unreadMessageCountChangeStreamHandler.onUnreadMessageCountChangeEvent(zendeskEvent.currentUnreadCount)
                } is ZendeskEvent.AuthenticationFailed -> {

                } else -> {

                }
            }
        }

        Zendesk.instance.addEventListener(zendeskListener)
    }

    fun loginUser(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!isInitialized) {
            result.error(Constants.ZendeskLoginFailureCode, Constants.ZendeskNotInitializedDescription, "")
            return
        }

        val jwt: String
        try {
            jwt = call.arguments as String
        } catch (e: Exception) {
            result.error(Constants.IncorrectArguments, Constants.LoginArgumentsErrorDescription, e.localizedMessage)
            return
        }

        Zendesk.instance.loginUser(
                jwt,
                successCallback = {
                    result.success(mapOf(Constants.IdKey to it.id, Constants.ExternalIdKey to it.externalId))
                },
                failureCallback = {
                    result.error(Constants.ZendeskLoginFailureCode, "Something went wrong on zendesk login stage", it.localizedMessage)
                },
        )
    }

    fun logoutUser(@NonNull result: MethodChannel.Result) {
        if (!isInitialized) {
            result.error(Constants.ZendeskLogoutFailureCode, Constants.ZendeskNotInitializedDescription, "")
            return
        }

        Zendesk.instance.logoutUser(
                successCallback = {
                    result.success(null)
                },
                failureCallback = {
                    result.error(Constants.ZendeskLogoutFailureCode, "Something went wrong on zendesk logout stage", it.localizedMessage)
                },
        )
    }

    fun showZendesk(@NonNull result: MethodChannel.Result, @NonNull activity: Activity) {
        if (!isInitialized) {
            result.error(Constants.ZendeskShowViewFailureCode, Constants.ZendeskNotInitializedDescription, "")
            return
        }

        Zendesk.instance.messaging.showMessaging(activity, Intent.FLAG_ACTIVITY_NEW_TASK)
        result.success(null)
    }
}