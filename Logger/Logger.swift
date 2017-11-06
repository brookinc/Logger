//
//  Logger.swift
//  https://github.com/brookinc/logger
//
//  To log a standard message to a channel, simply call Logger.log():
//    Logger.log(.network, "Packet received successfully.")
//
//  You can also specify a higher precedence level for your message:
//    Logger.log(.network, .warning, "Timed out waiting for packet!")
//
//  If you just want a print indicating where you are in the code, you don't even need to provide a message:
//    Logger.log(.network)
//
//  By default, all channels are printed, using the .initial option set, for all messages flagged .standard or higher.
//  In addition, even if you limit the channels being printed (see below), messages flagged .warning or .error will
//  be printed by default, even in channels that you've otherwise silenced.
//
//  To customize the prints you see, you simply change the relevant Logger properties:
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
//        // also print error messages from any channel, even ones you haven't chosen
//        Logger.overrideLevel = .error
//
//        // print the time and file location when printing each message
//        Logger.options = [.time, .file]
//
//  If you want to suppress all override prints (ie. warnings / errors from other channels), set the override level to .suppressAll:
//    Logger.overrideLevel = .suppressAll
//
//  ...or, to suppress all prints altogether, set the current level to .suppressAll:
//    Logger.currentLevel = .suppressAll
//
//  Addtional channels can be added in the Channels option set below as needed.
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
  logger_temp:
    name: "Logger Temporary Channel"
    regex: "\\.log\\W[^\\n\\r]*?(Logger\\.Channels)?\\.temp\\W"
    match_kinds:
      - identifier
    message: "The `.temp` print channel is only for temporary print statements."
    severity: warning
  logger_suppress_all:
    name: "Logger Suppress-All Level"
    regex: "\\.log\\W[^\\n\\r]+?(Logger\\.Level)?\\.suppressAll\\W"
    match_kinds:
      - identifier
    message: "Logging a message with level `.suppressAll` means that message will never be seen."
    severity: warning
*/

// If you do enable the above rules, the next line is needed to prevent them from triggering in this file.
// swiftlint:disable logger_enforce

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

        static let time =           Options(rawValue: 1 << 0)
        static let timeVerbose =    Options(rawValue: 1 << 1)
        static let file =           Options(rawValue: 1 << 2)
        static let fileVerbose =    Options(rawValue: 1 << 3)
        static let function =         Options(rawValue: 1 << 4)
        static let functionVerbose =  Options(rawValue: 1 << 5)
        static let thread =           Options(rawValue: 1 << 6)
        static let threadVerbose =    Options(rawValue: 1 << 7)
        static let channel =          Options(rawValue: 1 << 8)
        static let level =            Options(rawValue: 1 << 9)

        static let all =            Options(rawValue: UInt.max)
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

    static func log(_ messageChannel: Channels, _ messageLevel: Level, _ message: String = "", _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
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
                    formatter.dateFormat = "y-MM-dd H:m:ss.SSS"
                } else {
                    formatter.dateFormat = "H:m:ss"
                }
                print(formatter.string(from: Date()), terminator: " ")
            }
            if options.contains(.file) || options.contains(.fileVerbose) || message.isEmpty {
                var fileString = file
                if !options.contains(.fileVerbose) {
                    // just print the file name, not the full path
                    //let pathElements = file.split(separator: "/")  <-- TODO: Swift 4 way...
                    let pathElements = file.components(separatedBy: "/")
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
            if options.contains(.thread) || options.contains(.threadVerbose) {
                // print the current thread info -- it's not exposed directly, but we can parse it from the description
                // (technically, `Thread.name` is available, but in practice it appears to always be empty.)
                let str = Thread.current.description  // Sample description: "<NSThread: 0x1c007ebc0>{number = 1, name = main}"
                let threadNumber = str.substring(with: str.range(of: "number = ")?.upperBound ..< str.range(of: ",")?.lowerBound)
                var threadString = "[\(threadNumber)]"
                if options.contains(.threadVerbose) {
                    let threadAddress = str.substring(with: str.range(of: "0")?.lowerBound ..< str.range(of: ">")?.lowerBound)
                    let threadName = str.substring(with: str.range(of: "name = ")?.upperBound ..< str.range(of: "}")?.lowerBound)
                    let threadNameString = (threadName == "(null)") ? "" : " (\(threadName))"
                    threadString = "[\(threadNumber):\(threadAddress)\(threadNameString)]"
                }
                print(threadString, terminator: " ")
            }
            if options.contains(.channel) {
                // TODO: print(.network) yields "Channels(rawValue: 1)" -- can we cleanly and easily make it print the name instead?
                print("[\(messageChannel)]", terminator: " ")
            }
            if options.contains(.level) {
                print(messageLevel, terminator: " ")
            }
            print(message)
        }
    }

    static func log(_ messageChannel: Channels, _ message: String = "", _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
        // if no message level is specified, assume .standard
        log(messageChannel, .standard, message, file, line, function)
    }
}
