import ArgumentParser
import XcodeProject

public struct ListTargetsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list-targets",
        abstract: "List project targets."
    )

    @OptionGroup
    var options: ProjectReadOptions

    @Option(name: .customLong("file"), help: "Path to file - find targets for a specific file.")
    var filePath: String?

    @Option(name: .customLong("group"), help: "Path to group - find targets for a specific group.")
    var groupPath: String?

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let filePath = filePath?.asInputPath
        let groupPath = groupPath?.asInputPath

        let targets = if let groupPath {
            try project.targets.guessTargetsForGroup(groupPath)
        } else if let filePath {
            try project.targets.listTargetsForFile(filePath)
        } else {
            project.targets.listTargets()
        }

        for target in targets.map(\.name) {
            print(target)
        }
    }

    public func validate() throws {
        if filePath != nil, groupPath != nil {
            throw ValidationError("Only one of file-path or group-path can be provided")
        }
    }
}
