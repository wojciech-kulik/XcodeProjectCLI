import ArgumentParser

struct ListTargetsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list-targets",
        abstract: "List project targets."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("file"), help: "Path to file - find targets for a specific file.")
    var filePath: String?

    @Option(name: .customLong("group"), help: "Path to group - find targets for a specific group.")
    var groupPath: String?

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let filePath = filePath?.asInputPath
        let groupPath = groupPath?.asInputPath

        if let groupPath {
            guard groupPath.exists else {
                throw CLIError.groupNotFoundOnDisk(groupPath)
            }
        } else if let filePath {
            guard filePath.exists else {
                throw CLIError.fileNotFoundOnDisk(filePath)
            }
        }

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

    func validate() throws {
        if filePath != nil, groupPath != nil {
            throw ValidationError("Only one of file-path or group-path can be provided")
        }
    }
}
