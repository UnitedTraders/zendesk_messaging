//
//  ErrorUtils.swift
//  zendesk_messaging
//
//  Created by Aleksey Shepelev on 22.03.2022.
//

import Foundation

struct ErrorUtils {
    static public func buildError(title: String, details: String? = nil) -> FlutterError {
        return FlutterError.init(code: "NATIVE_ERR",
                    message: "Error: \(title)",
                    details: details)
    }
}
