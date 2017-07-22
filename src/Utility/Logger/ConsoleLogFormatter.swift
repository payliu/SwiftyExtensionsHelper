//
//  ConsoleLogFormat.swift
//  SwiftyExtensionsHelper
//
//  Created by Pay Liu on 2017-07-22.
//  Copyright © 2017 多多資訊有限公司. All rights reserved.
//

import Foundation
import CocoaLumberjack.DDDispatchQueueLogFormatter

public class ConsoleLogFormatter: DDDispatchQueueLogFormatter {

    let dateFormatter: DateFormatter

    override public init!() {

        self.dateFormatter = DateFormatter()
        self.dateFormatter.formatterBehavior = .behavior10_4
        self.dateFormatter.dateFormat = "HH:mm.ss.SSS"

        super.init()
    }

    override public func format(message logMessage: DDLogMessage) -> String? {

        var logLevel: String;

        switch logMessage.flag {

        case DDLogFlag.error:
            logLevel = "[ERROR]"

        case DDLogFlag.warning:
            logLevel = "[WARN ]"

        case DDLogFlag.info:
            logLevel = "[INFO ]"

        case DDLogFlag.debug:
            logLevel = "[DEBUG]"

        default:
            logLevel = "[VERBO]"
        }

        let dateTime = self.dateFormatter.string(from: logMessage.timestamp)

        return "\(dateTime) [\(logMessage.fileName):\(logMessage.function!):\(logMessage.line)]\(logLevel): \(logMessage.message)"
    }
}
