//
//  LumberjackNSLogger.swift
//  Pretty
//
//  Created by Pay Liu on 2017-07-21.
//  Copyright © 2017 多多資訊有限公司. All rights reserved.
//

import Foundation
import NSLogger
import CocoaLumberjack

/**
 * ref: http://swiftexample.info/snippet/lumberjacknsloggerswift_skerkewitz_swift
 * The `LumberjackNSLogger` class implements a [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)
 * logger sink which sends logs to [NSLogger](https://github.com/fpillet/NSLogger).
 *
 * Base on [XCDLumberjackNSLogger](https://github.com/0xced/XCDLumberjackNSLogger) of Cédric Luthi.
 */
public final class LumberjackNSLogger: NSObject, DDLogger {

    public var logFormatter: DDLogFormatter = NSLoggerLogFormatter()

    public let loggerName = "cocoa.lumberjack.NSLogger"

    /**
     * The opaque pointer to the underlying NSLogger struct.
     *
     * @discussion Use the underlying logger if you need fine-grained control. For example, you may want to call
     * `LoggerSetViewerHost(lubmerjackNSLogger.logger, host, port)` if you are in a Bonjour-hostile network. You may
     * also use this property to tweak the logger options with the `LoggerSetOptions` function.
     */
    fileprivate let logger: OpaquePointer

    /**
     * This property defines a relation between CocoaLumberjack contexts and NSLogger tags. The keys must be
     * `NSNumber` objects representing CocoaLumberjack contexts and the values must be `NSString` objects corresponding
     * to NSLogger tags.
     *
     * @discussion Framework authors are [encouraged to choose a context](https://github.com/CocoaLumberjack/CocoaLumberjack/blob/8adde11d0b16843cb45b81dc9b60d1430eb9b538/Documentation/CustomContext.md#example-2) to allow application developers to easily manage the log statements coming from their framework.
     * Unfortunately, a context is an NSInteger which is not appropriate for displaying in NSLogger. Use this property to translate unintelligible contexts into readable tags.
     *
     * For example, CocoaHTTPServer [defines a context](https://github.com/robbiehanson/CocoaHTTPServer/blob/52b2a64e9cbdb5f09cc915814a5fb68a45dd3707/Core/HTTPLogging.h#L55) of 80. In order to translate it to a `CocoaHTTPServer` tag, use  `lubmerjackNSLogger.tags = @{ @80 : @"CocoaHTTPServer" };`
     */
    public var tags: [Int: String]?

    private static let queueLabels: [String: String] = [
        "com.apple.root.user-interactive-qos": "User Interactive QoS", // QOS_CLASS_USER_INTERACTIVE
        "com.apple.root.user-initiated-qos": "User Initiated QoS", // QOS_CLASS_USER_INITIATED
        "com.apple.root.default-qos": "Default QoS", // QOS_CLASS_DEFAULT
        "com.apple.root.utility-qos": "Utility QoS", // QOS_CLASS_UTILITY
        "com.apple.root.background-qos": "Background QoS", // QOS_CLASS_BACKGROUND
        "com.apple.main-thread": "Main Queue"
    ]

    /**
     *  Initializes a logger with the specified bonjour service name.
     *
     *  @param bonjourServiceName The bonjour service name of the destination NSLogger desktop viewer. The bonjour service name may be nil.
     *
     *  @discussion Providing a bonjour service name is useful if you are several developers on the same network using NSLogger. If you are the only developer using NSLogger, you can pass nil or simply use the standard `init` method instead.
     *
     *  @return A logger with the specified bonjour service name.
     */
    public init(bonjourServiceName: String? = nil) {
        self.logger = LoggerInit();
        LoggerSetupBonjour(self.logger, nil, bonjourServiceName as CFString?)
        LoggerSetOptions(self.logger, (LoggerGetOptions(self.logger) & ~(UInt32(kLoggerOption_CaptureSystemConsole))))
    }

    deinit {
        LoggerStop(self.logger);
    }

    open func didAdd() {
        LoggerStart(self.logger)
    }

    open func flush() {
        LoggerFlush(self.logger, false);
    }

    open func log(message logMessage: DDLogMessage) {
        let level = log2f(Float(logMessage.flag.rawValue))
        let tag: String = self.tags?[logMessage.context] ?? logMessage.fileName
        self.setThreadName(message: logMessage)

        if let data = MessageAsData(logMessage.message) {
            LogDataToF(self.logger, logMessage.file, Int32(logMessage.line), logMessage.function, tag, Int32(level), data);
        } else {
//            let msg = self.logFormatter != nil ? self.logFormatter.format(message: logMessage)! : logMessage.message
            let msg = logMessage.message
            LogMessageRawToF(self.logger, logMessage.file, Int32(logMessage.line), logMessage.function, tag, Int32(level), msg);
        }
    }

    private final func setThreadName(message logMessage: DDLogMessage) {
        // There is no _thread name_ parameter for LogXXXToF functions, but we can abuse NSLogger’s thread name caching mechanism which uses the current thread dictionary
        let queueLabel = LumberjackNSLogger.queueLabels[logMessage.queueLabel] ?? logMessage.queueLabel;
        Thread.current.threadDictionary["__$NSLoggerThreadName$__"] = "\(logMessage.threadID) [\(queueLabel)]"
    }

    private final func MessageAsData(_ message: String) -> Data? {
        if message.hasPrefix("<") && message.hasSuffix(">") {
            let start = message.index(message.startIndex, offsetBy: 1)
            let end = message.index(message.endIndex, offsetBy: -1)
            let range = start..<end

            return message.substring(with: range)
                .replacingOccurrences(of: " ", with: "")
                .convertHexStringToData()
        }
        return nil;
    }
}

fileprivate extension String {

    func convertHexStringToData() -> Data? {
        guard self.characters.count % 2 == 0 else { return nil }
        var data = Data()
        var byteLiteral = ""
        for (index, character) in self.characters.enumerated() {
            if index % 2 == 0 {
                byteLiteral = String(character)
            } else {
                byteLiteral.append(character)
                guard let byte = UInt8(byteLiteral, radix: 16) else { return nil }
                data.append(byte)
            }
        }
        return data
    }
}
