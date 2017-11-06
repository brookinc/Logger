# Logger
A lightweight, flexible, channel-based logging tool for Swift.

## What it does
Logger offers an easy way to organize your `print()` statements into separate channels, and to control which channels are enabled and disabled:

```
Logger.log(.network, "Packet 1 received")  // will print
Logger.channels = [.ui, .rendering]
Logger.log(.network, "Packet 2 received")  // won't print
```

You can also log errors and warnings; by default they will print even if their channel is disabled:

```
Logger.log(.network, .warning, "Packet 1 is larger than expected.")  // will print
Logger.log(.network, .error, "Packet 2 is corrupt.")                 // will print
```

Logger also lets you print additional information along with each message:
- `.channel`: the channel to which the message was logged
- `.level`: the level at which the message was logged (`verbose`, `standard`, `warning`, `error`)
- `.time` / `.timeVerbose`: the date / time the message was logged
- `.file` / `.fileVerbose`: the file name and line number from which the message was logged
- `.function` / `.functionVerbose`: the function from which the message was logged
- `.thread` / `.threadVerbose`: the thread from which the message was logged

You can customize which information is printed at any time by updating `Logger.options`:

`Logger.options = [.time, .file]`

## How to use it
Just copy `Logger.swift` into your project and start logging. :)

## License
MIT License

Copyright (c) 2017 Brook Jones

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
