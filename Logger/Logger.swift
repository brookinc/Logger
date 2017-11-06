//
//  Logger.swift
//  https://github.com/brookinc/logger
//
//  To log a standard message to a channel, simply call Logger.log():
//    Logger.log(.network, "Packet received successfully.")
//
//  You can also specify a higher filter level for your message:
//    Logger.log(.network, .warning, "Timed out waiting for packet!")
//
//  By default, all channels are printed, with the .initial option set, for all messages flagged .standard or higher.
//  To customize this, you can do something like this:
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        // print only the channels I care about
//        Logger.channels = [.network, .rendering]
//        // print all messages flagged .verbose or higher in those channels
//        Logger.level = .verbose
//        // also make sure to print errors from any channel
//        Logger.overrideLevel = .error
//        // print the time and file location for each message
//        Logger.options = [.timestamp, .filename]
//
//  To turn off all override prints (ie. warnings / errors from other channels), set the override level to .suppressAll:
//    Logger.overrideLevel = .suppressAll
//
//  ...or to disable all prints, set the current level to .suppressAll:
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

import Foundation

class Logger {
    struct Channels: OptionSet {
        let rawValue: UInt

        // add extra channels here as needed
        static let fileIO =     Channels(rawValue: 1 << 0)
        static let network =    Channels(rawValue: 1 << 1)
        static let rendering =  Channels(rawValue: 1 << 2)
        static let ui =         Channels(rawValue: 1 << 3)

        static let temp =       Channels(rawValue: 1 << 63)  // Intended for local use only (and thus triggers a SwiftLint warning).

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

        static let dateTime  = Options(rawValue: 1 << 0)
        static let timestamp = Options(rawValue: 1 << 1)
        static let fullPath =  Options(rawValue: 1 << 2)
        static let filename =  Options(rawValue: 1 << 3)
        static let channel =   Options(rawValue: 1 << 4)
        static let level =     Options(rawValue: 1 << 5)

        static let all =       Options(rawValue: UInt.max)
        static let initial: Options = [
            .timestamp,
            .filename,
            .level
        ]
    }

    // default initial settings
    static var channels: Channels = .all
    static var level: Level = .standard
    static var overrideLevel: Level = .warning
    static var options: Options = .initial

    static func log(_ messageChannel: Channels, _ messageLevel: Level, _ message: String, _ file: String = #file, _ line: Int = #line) {
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
            if options.contains(.dateTime) || options.contains(.timestamp) {
                if !options.contains(.dateTime) {
                    // TODO: if .dateTime isn't set, we should only print the time
                }
                print(Date().description, terminator: " ")
            }
            if options.contains(.fullPath) || options.contains(.filename) {
                var fileString = file
                if !options.contains(.fullPath) {
                    //let pathElements = file.split(separator: "/")  <-- TODO: Swift 4 way...
                    let pathElements = file.components(separatedBy: "/")
                    if let fileName = pathElements.last {
                        //fileString = String(fileName)  <-- TODO: Swift 4 way...
                        fileString = fileName
                    }
                }
                print("\(fileString):\(line)", terminator: " ")
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

    static func log(_ messageChannel: Channels, _ message: String, _ file: String = #file, _ line: Int = #line) {
        // if no message level is specified, assume .standard
        log(messageChannel, .standard, message, file, line)
    }
}
