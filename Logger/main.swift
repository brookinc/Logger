//
//  main.swift
//  https://github.com/brookinc/logger
//
//  Some simple usage examples of the Logger class.
//

// log a simple message with the default options
Logger.log(.ui, "Application loaded.")                          // will print (all channels enabled by default)

// log a bare message that just prints where we are in the code
Logger.log(.temp)                                               // will print the file name and line number

// customize our output options and enabled channels
Logger.options = [.file, .channel]
Logger.channels = [.ui, .rendering]

// log some more standard messages to various channels
Logger.log(.rendering, "Rendering initialized.")                // will print (channel still enabled)
Logger.log(.network, "Network functioning normally.")           // won't print (channel no longer enabled)
Logger.log(.fileIO, "File system is accessible.")               // wont' print (channel no longer enabled)

// log a warning and an error
Logger.log(.ui, .error, "Couldn't display the image.")          // will print (channel still enabled)
Logger.log(.network, .warning, "Couldn't retrieve the image.")  // will print (warnings and errors from any channel are printed by default)

// change our override setting to no longer show errors or warnings from disabled channels
Logger.overrideLevel = .suppressAll

// log another error to a disabled channel
Logger.log(.fileIO, .error, "Couldn't access the image.")       // won't print (channel disabled and override prints disabled)
