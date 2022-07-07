package com.unitedtraders.mobile.zendesk_messaging

class Constants {
    companion object {
        const val ChannelKey = "channelKey"
        const val ShouldInterceptUrlHandlingKey = "shouldInterceptUrlHandling"
        const val IdKey = "id"
        const val ExternalIdKey = "externalId"

        const val InitializeCommand = "zendeskInitialize"
        const val LoginCommand = "zendeskLogin"
        const val LogoutCommand = "zendeskLogout"
        const val ShowViewCommand = "showZendesk"

        const val IncorrectArguments = "IncorrectArguments"

        const val ZendeskLoginFailureCode = "ZendeskLoginFailure"
        const val ZendeskLogoutFailureCode = "ZendeskLogoutFailure"
        const val ZendeskInitializationFailureCode = "ZendeskInitializationFailure"
        const val ZendeskShowViewFailureCode = "ZendeskShowViewFailureCode"
        const val PlatformZendeskErrorCode = "ZendeskError"

        const val ZendeskNotInitializedDescription = "Zendesk was not initialize. Call initialize method first"
        const val LoginArgumentsErrorDescription = "jwt as String argument was expected"
        const val InitializeArgumentsErrorDescription = "channel key as String argument was expected"
        const val PlatformZendeskErrorDescription = "Something went wrong on zendesk platform side"
    }
}