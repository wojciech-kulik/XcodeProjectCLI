import Foundation

enum CLIError: Error, CustomStringConvertible {
    case invalidInput(String)
    case invalidOperation(String)
    case unexpectedValue(String)
    case generic(String)

    var description: String {
        switch self {
        case .invalidInput(let message):
            return message
        case .invalidOperation(let message):
            return message
        case .unexpectedValue(let message):
            return message
        case .generic(let message):
            return message
        }
    }
}
