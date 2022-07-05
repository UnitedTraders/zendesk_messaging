package com.unitedtraders.mobile.zendesk_messaging

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import zendesk.android.Zendesk
import zendesk.android.events.ZendeskEvent
import zendesk.android.events.ZendeskEventListener
import zendesk.android.messaging.Messaging
import zendesk.android.messaging.MessagingDelegate
import zendesk.android.messaging.UrlSource
import zendesk.messaging.android.DefaultMessagingFactory


class ZendeskMessaging(
    private var unreadMessageCountChangeStreamHandler: UnreadMessageCountChangeStreamHandler,
    private var urlToHandleInAppStreamHandler: UrlToHandleInAppStreamHandler,
) {
    private var isInitialized: Boolean = false

    fun initializeZendesk(
        @NonNull call: MethodCall,
        @NonNull result: MethodChannel.Result,
        @NonNull activity: Activity
    ) {
        val channelKey: String
        val shouldInterceptUrl: Boolean
        try {
            val arguments = call.arguments as Map<*, *>
            channelKey = arguments[Constants.ChannelKey] as String
            shouldInterceptUrl = arguments[Constants.ShouldInterceptUrlHandlingKey] as Boolean
        } catch (e: Exception) {
            result.error(
                Constants.IncorrectArguments,
                Constants.InitializeArgumentsErrorDescription,
                e.localizedMessage
            )
            return
        }

        try {
            Zendesk.initialize(
                activity,
                channelKey,
                successCallback = {
                    isInitialized = true
                    initializeZendeskEventListeners(activity, shouldInterceptUrl)
                    result.success(null)
                },
                failureCallback = {
                    result.error(
                        Constants.ZendeskInitializationFailureCode,
                        "Something went wrong on zendesk initializing stage",
                        it.localizedMessage
                    )
                },
                DefaultMessagingFactory(),
            )
        } catch (e: Exception) {
            result.error(
                Constants.PlatformZendeskErrorCode,
                Constants.PlatformZendeskErrorDescription,
                e.localizedMessage
            )
        }
    }

    private fun initializeZendeskEventListeners(
        @NonNull activity: Activity,
        @NonNull shouldInterceptUrl: Boolean
    ) {
        val zendeskListener = ZendeskEventListener { zendeskEvent: ZendeskEvent ->
            when (zendeskEvent) {
                is ZendeskEvent.UnreadMessageCountChanged -> {
                    unreadMessageCountChangeStreamHandler.onUnreadMessageCountChangeEvent(
                        zendeskEvent.currentUnreadCount
                    )
                }
                is ZendeskEvent.AuthenticationFailed -> {

                }
                else -> {

                }
            }
        }

        Zendesk.instance.addEventListener(zendeskListener)

        if (shouldInterceptUrl) {
            Messaging.setDelegate(object : MessagingDelegate() {
                override fun shouldHandleUrl(url: String, urlSource: UrlSource): Boolean {
                    val intent = Intent(activity.applicationContext, activity.javaClass)
                    intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    activity.startActivity(intent)

                    urlToHandleInAppStreamHandler.onUrlToHandleInAppEvent(url)
                    return false
                }
            })
        }
    }

    fun loginUser(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!isInitialized) {
            result.error(
                Constants.ZendeskLoginFailureCode,
                Constants.ZendeskNotInitializedDescription,
                ""
            )
            return
        }

        val jwt: String
        try {
            jwt = call.arguments as String
        } catch (e: Exception) {
            result.error(
                Constants.IncorrectArguments,
                Constants.LoginArgumentsErrorDescription,
                e.localizedMessage
            )
            return
        }

        try {
            Zendesk.instance.loginUser(
                jwt,
                successCallback = {
                    result.success(
                        mapOf(
                            Constants.IdKey to it.id,
                            Constants.ExternalIdKey to it.externalId
                        )
                    )
                },
                failureCallback = {
                    result.error(
                        Constants.ZendeskLoginFailureCode,
                        "Something went wrong on zendesk login stage",
                        it.localizedMessage
                    )
                },
            )
        } catch (e: Exception) {
            result.error(
                Constants.PlatformZendeskErrorCode,
                Constants.PlatformZendeskErrorDescription,
                e.localizedMessage
            )
        }
    }

    fun logoutUser(@NonNull result: MethodChannel.Result) {
        if (!isInitialized) {
            result.error(
                Constants.ZendeskLogoutFailureCode,
                Constants.ZendeskNotInitializedDescription,
                ""
            )
            return
        }

        try {
            Zendesk.instance.logoutUser(
                successCallback = {
                    result.success(null)
                },
                failureCallback = {
                    result.error(
                        Constants.ZendeskLogoutFailureCode,
                        "Something went wrong on zendesk logout stage",
                        it.localizedMessage
                    )
                },
            )
        } catch (e: Exception) {
            result.error(
                Constants.PlatformZendeskErrorCode,
                Constants.PlatformZendeskErrorDescription,
                e.localizedMessage
            )
        }
    }

    fun showZendesk(@NonNull result: MethodChannel.Result, @NonNull activity: Activity) {
        if (!isInitialized) {
            result.error(
                Constants.ZendeskShowViewFailureCode,
                Constants.ZendeskNotInitializedDescription,
                ""
            )
            return
        }

        try {
            Zendesk.instance.messaging.showMessaging(activity, Intent.FLAG_ACTIVITY_NEW_TASK)
            result.success(null)
        } catch (e: Exception) {
            result.error(
                Constants.PlatformZendeskErrorCode,
                Constants.PlatformZendeskErrorDescription,
                e.localizedMessage
            )
        }
    }
}