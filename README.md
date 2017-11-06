# Logger
A lightweight, flexible, channel-based logging tool for Swift.

## What it does
Logger offers an easy way to organize your `print()` statements into separate channels, and to control which channels are enabled and disabled:

```
Logger.log(.network, "Packet 1 received")  // will print (all channels are enabled by default)
Logger.channels = [.ui, .rendering]
Logger.log(.network, "Packet 2 received")  // won't print
```

You can also log errors and warnings; by default they will print even if their channel is disabled:

```
Logger.log(.network, .warning, "Packet 1 is larger than expected.")  // will print
Logger.log(.network, .error, "Packet 2 is corrupt.")                 // will print
```

If you just want a print indicating where you are in the code, you don't even need to provide a message:

```
Logger.log(.ui)  // will print file name + line number
```

Logger also lets you print additional information along with each message:
- `.channel`: the channel to which the message was logged
- `.level`: the level at which the message was logged (`verbose`, `standard`, `warning`, `error`)
- `.time` / `.timeVerbose`: the date / time the message was logged
- `.file` / `.fileVerbose`: the file name and line number from which the message was logged
- `.function` / `.functionVerbose`: the function from which the message was logged
- `.thread` / `.threadVerbose`: the thread from which the message was logged
- `.assertOnError`: this option will trigger an assert failure whenever an error is logged

You can customize which information is printed at any time by updating `Logger.options`:

`Logger.options = [.time, .file, .threadVerbose]`

If you want to do any custom handling of Logger messages, you can create a delegate:

```
class MyLogger: LoggerDelegate {
    func log(_ messageChannel: Logger.Channels, _ messageLevel: Logger.Level, _ message: String, _ file: StaticString, _ line: UInt, _ function: String) {
        if messageLevel == .error {
            MyErrorDatabase.addRow(file: file, line: line, message: message)
        }
    }
}
```

...and register it:

```
let myLogger = MyLogger()
Logger.delegates.append(myLogger)
```

Your delegate object will receive all messages that get logged; the .channel and .level filters are not applied to delegates.

## How to use it
Just copy `Logger.swift` into your project and start logging. :)

(Additionally, if you use [SwiftLint](https://github.com/realm/SwiftLint), you can copy Logger's SwiftLint rules from the top of `Logger.swift` into your project's `.swiftlint.yml` file.)

## License
MIT License

Copyright (c) 2017 Brook Jones

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
