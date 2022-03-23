package com.unitedtraders.mobile.zendesk_messaging

class Constants {
    companion object {
        const val IncorrectArguments = "IncorrectArguments"
        const val InitializeCommand = "zendeskInitialize"
        const val LoginCommand = "zendeskLogin"
        const val LogoutCommand = "zendeskLogout"
        const val ShowViewCommand = "showZendesk"
        const val ZendeskLoginFailureCode = "ZendeskLoginFailure"
        const val ZendeskLogoutFailureCode = "ZendeskLogoutFailure"
        const val ZendeskInitializationFailureCode = "ZendeskInitializationFailure"
        const val ZendeskShowViewFailureCode = "ZendeskShowViewFailureCode"
        const val ZendeskNotInitializedDescription = "Zendesk was not initialize. Call initialize method first"
        const val LoginArgumentsErrorDescription = "jwt as String argument was expected"
        const val InitializeArgumentsErrorDescription = "channel key as String argument was expected"
    }
}