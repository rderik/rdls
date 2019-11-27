import Foundation
import AppKit

func processCommand(_ fd: CFFileDescriptorNativeDescriptor = STDIN_FILENO) -> Int8 {
    let fileH = FileHandle(fileDescriptor: fd)
    let input = String(data: fileH.availableData,
                         encoding: .utf8)?.trimmingCharacters(
                            in: .whitespacesAndNewlines) ?? ""
    let inputS = input.components(separatedBy: " ")
    let (command, arguments) = (inputS[0], inputS.dropFirst())
    switch command {
    case "exit":
      return -1
    case "get":
      if arguments.count < 2 {
        return 1
      }
      switch arguments[1] {
      case "uti":
        if let result = LSCopyDefaultRoleHandlerForContentType(arguments[2] as CFString, .all) {
          let handler = result.takeRetainedValue() as String
          print(handler, terminator: "\n% ")
        } else {
          print("handler not found for UTI: \(arguments[2])", terminator: "\n% ")
        }
      case "url":
        if let result = LSCopyDefaultHandlerForURLScheme(arguments[2] as CFString) {
          let handler = result.takeRetainedValue() as String
          print(handler, terminator: "\n% ")
        } else {
          print("handler not found for URL scheme: \(arguments[2])", terminator: "\n% ")
        }
      default:
        return 1
      }
      return 0
    case "set":
      if arguments.count < 3 {
        return 1
      }
      switch arguments[1] {
      case "uti":
        let uti = arguments[2] as CFString
        let bundleID = arguments[3] as CFString
        let result = LSSetDefaultRoleHandlerForContentType(uti, .viewer, bundleID) 
        if result == 0 {
          print("Successfully set handler with bundle id: \(bundleID) for UTI: \(uti)", terminator: "\n% ")
        } else {
          print("Couldn't set handler with bundle id: \(bundleID) for UTI: \(uti)", terminator: "\n% ")
        }
      case "url":
        let urlScheme = arguments[2] as CFString
        let bundleID = arguments[3] as CFString
        let result = LSSetDefaultHandlerForURLScheme(urlScheme, bundleID) 
        if result == 0 {
          print("Successfully set handler with bundle id: \(bundleID) for URL Scheme: \(urlScheme)", terminator: "\n% ")
        } else {
          print("Couldn't set handler with bundle id: \(bundleID) for URL Scheme: \(urlScheme)", terminator: "\n% ")
        }
      default:
        return 1
      }
      return 0
    case "":
        print("", terminator: "\n% ")
        return 0
    default:
      return 1
    }
}

print("Welcome to rdls a Launch Service tool", terminator: "\n% ")
fflush(__stdoutp)
outerLoop: while true {
    let result = processCommand()
    fflush(__stdoutp)
    switch result {
    case -1:
        break outerLoop
    case 1:
        print("Unknown command.\nUsage:\n  get [uti|url] <identifier>\n  set [uti|url] <identifier> <handler's bundle id>", terminator: "\n% ")
    default:
        break
    }
    fflush(__stdoutp)
}
print("Bye bye now.")
