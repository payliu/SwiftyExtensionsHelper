//
//  NSLoggerLogFormatter.swift
//  SwiftyExtensionsHelper
//
//  Created by Pay Liu on 2017-07-22.
//  Copyright © 2017 多多資訊有限公司. All rights reserved.
//

import Foundation
import CocoaLumberjack

class NSLoggerLogFormatter: NSObject, DDLogFormatter {

    override init() {
        super.init()
    }

    func format(message logMessage: DDLogMessage) -> String? {
        return logMessage.message
    }
}
