import Foundation

enum CLIError: Error, CustomStringConvertible {
    case invalidParameter(String)
    case generic(String)

    var description: String {
        switch self {
        case .invalidParameter(let message):
            return message
        case .generic(let message):
            return message
        }
    }
}
