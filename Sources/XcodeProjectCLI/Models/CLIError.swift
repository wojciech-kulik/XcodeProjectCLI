import Foundation

enum CLIError: Error, Equatable, CustomStringConvertible {
    case fileNotFoundOnDisk(InputPath)
    case fileNotFoundInProject(InputPath)
    case groupNotFoundOnDisk(InputPath)
    case groupNotFoundInProject(InputPath)
    case rootGroupNotFound
    case xcodeProjectNotFound
    case missingTargets([String])

    var description: String {
        switch self {
        case .fileNotFoundOnDisk(let filePath):
            return "File not found on disk: \(filePath)"
        case .fileNotFoundInProject(let filePath):
            return "File not found in the project: \(filePath)"
        case .groupNotFoundOnDisk(let groupPath):
            return "Group not found on disk: \(groupPath)"
        case .groupNotFoundInProject(let groupPath):
            return "Group not found in the project: \(groupPath). Use --create-groups to create missing groups."
        case .missingTargets(let targets):
            return "Targets not found in the project: \(targets.joined(separator: ", "))"
        case .rootGroupNotFound:
            return "Root group not found in the project."
        case .xcodeProjectNotFound:
            return "Xcode project file not found."
        }
    }
}
