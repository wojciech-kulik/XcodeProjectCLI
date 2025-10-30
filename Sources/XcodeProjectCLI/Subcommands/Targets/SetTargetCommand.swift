import ArgumentParser

struct SetTargetCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "set-target",
        abstract: "Set target for an existing file."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("file"), help: "Path to file.")
    var filePath: String

    @Option(help: "Comma separated list of target names.")
    var targets: String

    private var parsedTargets: [String] = []

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        try project.targets.setTargets(parsedTargets, for: filePath)
        try project.save()
    }

    mutating func validate() throws {
        let targets = targets.components(separatedBy: ",").filter { !$0.isEmpty }

        guard !targets.isEmpty else {
            throw ValidationError("targets field required")
        }

        parsedTargets = targets
    }
}
