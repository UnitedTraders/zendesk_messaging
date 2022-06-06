package com.unitedtraders.mobile.zendesk_messaging

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import zendesk.messaging.android.push.PushNotifications
import zendesk.messaging.android.push.PushResponsibility

class ZendeskMessagingNotificationService: FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        when (PushNotifications.shouldBeDisplayed(message.data)) {
            PushResponsibility.MESSAGING_SHOULD_DISPLAY -> {
                PushNotifications.displayNotification(context = this, messageData = message.data)
            }
            PushResponsibility.MESSAGING_SHOULD_NOT_DISPLAY -> {
                // This push belongs to Messaging but it should not be displayed to the end user
            }
            PushResponsibility.NOT_FROM_MESSAGING -> {
                // This push does not belong to Messaging
            }
        }
    }

    override fun onNewToken(token: String) {
        PushNotifications.updatePushNotificationToken(token)
    }
}