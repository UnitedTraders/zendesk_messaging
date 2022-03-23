//
//  Constants.swift
//  zendesk_messaging
//
//  Created by Aleksey Shepelev on 22.03.2022.
//

import Foundation

struct Constants {
    static let IncorrectArguments = "IncorrectArguments"
    static let IncorrectCommand = "IncorrectCommand"
    static let ZendeskLoginFailureCode = "ZendeskLoginFailure"
    static let ZendeskLogoutFailureCode = "ZendeskLogoutFailure"
    static let ZendeskInitializationFailureCode = "ZendeskInitializationFailure"
    static let ZendeskShowViewFailureCode = "ZendeskShowViewFailureCode"
    static let ZendeskNotInitializedDescription = "Zendesk was not initialize. Call initialize method first"
    static let InitializeCommand = "zendeskInitialize"
    static let LoginCommand = "zendeskLogin"
    static let LogoutCommand = "zendeskLogout"
    static let ShowViewCommand = "showZendesk"
    static let LoginArgumentsErrorDescription = "jwt as String argument was expected"
    static let InitializeArgumentsErrorDescription = "channel key as String argument was expected"
    static let IdKey = "id"
    static let ExternalIdKey = "externalId"
}
