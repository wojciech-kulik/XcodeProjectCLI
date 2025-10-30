import ArgumentParser

struct AddFileCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add-file",
        abstract: "Add a file to specified targets in the project."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("file"), help: "Path to file.")
    var filePath: String

    @Option(help: "Comma separated list of target names.")
    var targets: String?

    @Flag(
        help: "If set and no targets are specified, the tool will attempt to guess the appropriate targets based on the file's location."
    )
    var guessTarget = false

    @Flag(help: "If set, the tool will create missing groups in the project structure when adding the file.")
    var createGroups = false

    private var parsedTargets: [String] = []

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        try project.files.addFile(
            filePath,
            toTargets: parsedTargets,
            guessTarget: guessTarget,
            createGroups: createGroups
        )
        try project.save()
    }

    mutating func validate() throws {
        let targets = targets?.components(separatedBy: ",").filter { !$0.isEmpty }

        guard targets?.isEmpty == false || guessTarget else {
            throw ValidationError("--targets parameter is required unless --guess-target is specified")
        }

        parsedTargets = targets ?? []
    }
}
