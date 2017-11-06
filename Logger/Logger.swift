//
//  Logger.swift
//  https://github.com/brookinc/logger
//
//  Logger is a structured, flexible replacement for Swift's built-in print() function. With it, you can filter
//  your print statements into different channels, assign them different priorities, and easily control at
//  run-time which statements get printed, and what extra information accompanies them.
//
//  To log a standard message to a channel, simply call Logger.log():
//    Logger.log(.network, "Packet received successfully.")
//
//  You can also specify a higher (or lower) priority level for your message:
//    Logger.log(.network, .warning, "Timed out waiting for packet!")
//    Logger.log(.network, .verbose, "Waiting for packet...")
//
//  If you just want a print that indicates where you are in the code, you don't even need to provide a message:
//    Logger.log(.temp)
//
//  You can enable any or all of the following output options:
//    .channel:                    prints the channel to which the message was logged
//    .level:                      prints the priority level at which the message was logged (verbose, standard, warning, or error)
//    .time/.timeVerbose           prints the timestamp at which the message was logged
//    .file/.fileVerbose:          prints file and line number from which the message was logged
//    .function/.functionVerbose:  prints the name of the function from which the message was logged
//    .thread/.threadVerbose:      prints the thread from which the message was logged
//
//  You can also enable the .assertOnError option, which will trigger an assert any time an (unsuppressed)
//  error message is logged.
//
//  By default, all channels are printed (using the .initial option set), for all messages flagged .standard or higher.
//  In addition, even if you limit the channels being printed (see below), messages flagged .warning or .error will
//  (by default) still be printed for all channels.
//
//  To customize which prints you see, and how they're printed, you simply change the relevant Logger properties:
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        ...
//        // print only the messages sent to one channel:
//        Logger.channels = .network
//        // ...or to a few channels:
//        Logger.channels = [.network, .rendering]
//        // ...or to all channels but one:
//        Logger.channels = Logger.Channels.all.subtracting(.network)
//        // ...or to all channels but a few:
//        Logger.channels = Logger.Channels.all.subtracting([.network, .rendering])
//
//        // print all messages flagged .verbose or higher in the chosen channels
//        Logger.level = .verbose
//
//        // from suppressed channels, only print error messages (the default override level is .warning,
//        // which prints both warnings and errors)
//        Logger.overrideLevel = .error
//        // ...or, to completely silence suppressed channels (ie. don't even print warnings or errors from those channels):
//        Logger.overrideLevel = .suppressAll
//
//        // print the time, file location, and current thread for each logged message
//        Logger.options = [.time, .file, .thread]
//
//  If you want to completely suppress all messages from all channels, you can set the current level to .suppressAll:
//    Logger.level = .suppressAll
//
//  You can create your own delegate class if you want to do additional processing or tracking of Logger messages. Simply
//  create a class which implements the LoggerDelegate protocol:
//    class MyLogger: LoggerDelegate {
//        func log(_ messageChannel: Logger.Channels, _ messageLevel: Logger.Level, _ message: String, _ file: StaticString, _ line: UInt, _ function: String) {
//            if messageLevel == .error {
//                MyErrorDatabase.addRow(file: file, line: line, message: message)
//            }
//        }
//    }
//  ...and then register an instance of that class with Logger:
//    let myLogger = MyLogger()
//    Logger.delegates.append(myLogger)
//
//  Your delegate object will receive all messages logged to all channels at all levels; the .channels and .level
//  filters are not applied to delegates.
//
//  Addtional channels can be added as needed in the Channels option set below.
//
//  LICENSE:
//  MIT License
//
//  Copyright (c) 2017 Brook Jones
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

/*
# SwiftLint Support
# If you use SwiftLint (http://github.com/realm/SwiftLint), you may wish to add these rules to your .swiftlint.yml file:
custom_rules:
  logger_enforce:
    name: "Logger Enforcement"
    regex: "[^.](?<!func )print\\s*?\\("
    match_kinds:
      - identifier
    message: "Use `Logger.log()` instead of `print()`, so that console output can be easily filtered."
    severity: warning
  logger_error_usage:
    name: "Logger Error Usage"
    regex: "Logger\\.log\\W[^\\n\\r\"]+?(?<!\\.error,\\s)\"[^\"]*?[Ee][Rr][Rr][Oo][Rr]"
    match_kinds:
      - identifier
      - string
    message: "Use the `.error` level when logging errors."
    severity: warning
  logger_warning_usage:
    name: "Logger Warning Usage"
    regex: "Logger\\.log\\W[^\\n\\r\"]+?(?<!\\.warning,\\s)\"[^\"]*?[Ww][Aa][Rr][Nn][Ii][Nn][Gg]"
    match_kinds:
      - identifier
      - string
    message: "Use the `.warning` level when logging warnings."
    severity: warning
  logger_temp:
    name: "Logger Temporary Channel"
    regex: "Logger\\.log\\W[^\\n\\r]*?(Logger\\.Channels)?\\.temp\\W"
    match_kinds:
      - identifier
    message: "The `.temp` print channel is only for temporary print statements."
    severity: warning
  logger_suppress_all:
    name: "Logger Suppress-All Level"
    regex: "Logger\\.log\\W[^\\n\\r]+?(Logger\\.Level)?\\.suppressAll\\W"
    match_kinds:
      - identifier
    message: "Logging a message with level `.suppressAll` means that message will never be seen."
    severity: warning
*/

// (These comment lines are then needed to prevent SwiftLint from triggering in this file:)
// swiftlint:disable logger_enforce
// swiftlint:disable function_parameter_count

import Foundation

class Logger {
    struct Channels: OptionSet {
        let rawValue: UInt

        // add extra channels here as needed
        static let fileIO =     Channels(rawValue: 1 << 0)
        static let network =    Channels(rawValue: 1 << 1)
        static let rendering =  Channels(rawValue: 1 << 2)
        static let ui =         Channels(rawValue: 1 << 3)

        static let temp =       Channels(rawValue: 1 << 63)  // Intended for local use only (and thus triggers a SwiftLint warning)

        static let all =        Channels(rawValue: UInt.max)
    }

    enum Level: Int {
        case verbose
        case standard
        case warning
        case error
        case suppressAll
    }

    struct Options: OptionSet {
        let rawValue: UInt

        static let channel =          Options(rawValue: 1 << 0)
        static let level =            Options(rawValue: 1 << 1)
        static let time =             Options(rawValue: 1 << 2)
        static let timeVerbose =      Options(rawValue: 1 << 3)
        static let file =             Options(rawValue: 1 << 4)
        static let fileVerbose =      Options(rawValue: 1 << 5)
        static let function =         Options(rawValue: 1 << 6)
        static let functionVerbose =  Options(rawValue: 1 << 7)
        static let thread =           Options(rawValue: 1 << 8)
        static let threadVerbose =    Options(rawValue: 1 << 9)
        static let assertOnError =    Options(rawValue: 1 << 10)

        static let all =              Options(rawValue: UInt.max)
        static let initial: Options = [
            .time,
            .file
        ]
    }

    // default initial settings
    static var channels: Channels = .all
    static var level: Level = .standard
    static var overrideLevel: Level = .warning
    static var options: Options = .initial

    // delegates
    static var delegates: [LoggerDelegate] = []

    static func log(_ messageChannel: Channels, _ messageLevel: Level, _ message: String = "", _ file: StaticString = #file, _ line: UInt = #line, _ function: String = #function) {
        for delegate in delegates {
            delegate.log(messageChannel, messageLevel, message, file, line, function)
        }
        
        guard level.rawValue < Level.suppressAll.rawValue else {
            return
        }

        guard messageLevel.rawValue < Level.suppressAll.rawValue else {
            print("Logger warning: message logged from \(file):\(line) with a .suppressAll level, so it will never be seen.")
            return
        }

        if (channels.contains(messageChannel) && level.rawValue <= messageLevel.rawValue)
            || overrideLevel.rawValue <= messageLevel.rawValue {
            if messageLevel == .warning {
                print("Warning:", terminator: " ")
            } else if messageLevel == .error {
                print("Error:", terminator: " ")
            }
            if options.contains(.time) || options.contains(.timeVerbose) {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                if options.contains(.timeVerbose) {
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                } else {
                    formatter.dateFormat = "HH:mm:ss"
                }
                print(formatter.string(from: Date()), terminator: " ")
            }
            if options.contains(.channel) {
                // don't add a trailing space if we're going to print the thread next
                let terminator = (options.contains(.thread) || options.contains(.threadVerbose)) ? "" : " "
                // print the log2() of the raw value, so it more clearly matches the channel assignment value
                print("[ch\(Int(log2(Double(messageChannel.rawValue))))]", terminator: terminator)
                // TODO: is there a way to actually print the channel name as a string, without having
                // to manually maintain a separate array of strings?
            }
            if options.contains(.thread) || options.contains(.threadVerbose) {
                // print the current thread info -- it's not exposed directly, but we can parse it from the description
                // (technically, `Thread.name` is available, but in practice it appears to always be empty.)
                let str = Thread.current.description  // Sample description: "<NSThread: 0x1c007ebc0>{number = 1, name = main}"
                let threadNumber = str.substring(with: str.range(of: "number = ")?.upperBound ..< str.range(of: ",")?.lowerBound)
                var threadString = "[t\(threadNumber)]"
                if options.contains(.threadVerbose) {
                    let threadAddress = str.substring(with: str.range(of: "0")?.lowerBound ..< str.range(of: ">")?.lowerBound)
                    let threadName = str.substring(with: str.range(of: "name = ")?.upperBound ..< str.range(of: "}")?.lowerBound)
                    let threadNameString = (threadName == "(null)") ? "" : " (\(threadName))"
                    threadString = "[\(threadNumber):\(threadAddress)\(threadNameString)]"
                }
                print(threadString, terminator: " ")
            }
            if options.contains(.level) {
                print(messageLevel, terminator: " ")
            }
            if options.contains(.file) || options.contains(.fileVerbose) || message.isEmpty {
                var fileString = file.description
                if !options.contains(.fileVerbose) {
                    // just print the file name, not the full path
                    //let pathElements = file.split(separator: "/")  <-- TODO: Swift 4 way...
                    let pathElements = file.description.components(separatedBy: "/")
                    if let fileName = pathElements.last {
                        //fileString = String(fileName)  <-- TODO: Swift 4 way...
                        fileString = fileName
                    }
                }
                print("\(fileString):\(line)", terminator: " ")
            }
            if options.contains(.function) || options.contains(.functionVerbose) || message.isEmpty {
                var functionString = function
                if !options.contains(.functionVerbose) {
                    // just print the function name, without the argument names
                    if let parenthesesIndex = function.range(of: "(")?.lowerBound {
                        functionString = function.substring(with: function.startIndex ..< parenthesesIndex) + "()"
                    }
                }
                print("\(functionString)", terminator: " ")
            }
            print(message)

            if options.contains(.assertOnError) && messageLevel == .error {
                assertionFailure(message, file: file, line: line)
            }
        }
    }

    static func log(_ messageChannel: Channels, _ message: String = "", _ file: StaticString = #file, _ line: UInt = #line, _ function: String = #function) {
        // if no message level is specified, assume .standard
        log(messageChannel, .standard, message, file, line, function)
    }

    // experimental / undocumented way to read the executable's filename and path
    // (see https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20161128/004143.html)
    static func appName(_ dsoHandle: UnsafeRawPointer = #dsohandle) -> String {
        var dlInformation: dl_info = dl_info()
        dladdr(dsoHandle, &dlInformation)
        let path = String(cString: dlInformation.dli_fname)
        var appString = path
        let pathElements = path.components(separatedBy: "/")
        if pathElements.count > 2 {
            appString = pathElements[pathElements.count - 2]
        }
        return appString
    }
}

protocol LoggerDelegate: class {
    func log(_ messageChannel: Logger.Channels, _ messageLevel: Logger.Level, _ message: String, _ file: StaticString, _ line: UInt, _ function: String)
}
