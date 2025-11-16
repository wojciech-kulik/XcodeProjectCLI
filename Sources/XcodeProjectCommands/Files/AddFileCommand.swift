import ArgumentParser
import XcodeProject

public struct AddFileCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "add-file",
        abstract: "Add a file to specified targets."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("file"), help: .init("File path.", valueName: "file-path"))
    var filePath: String

    @Option(help: "Comma separated list of target names.")
    var targets: String?

    @Flag(help: "If set and no targets are specified, the tool will attempt to guess the targets based on the file's location.")
    var guessTarget = false

    @Flag(help: "If set, the tool will create missing groups in the project structure.")
    var createGroups = false

    @Flag(help: "If set, the tool will print the targets the file was added to.")
    var printTargets = false

    private var parsedTargets: [String] = []

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw XcodeProjectError.fileNotFoundOnDisk(filePath)
        }

        let targets = try project.files.addFile(
            filePath,
            toTargets: parsedTargets,
            guessTarget: guessTarget,
            createGroups: createGroups
        )
        try project.save()

        if printTargets {
            targets.forEach { print($0) }
        }
    }

    public mutating func validate() throws {
        let targets = targets?.components(separatedBy: ",").filter { !$0.isEmpty }

        guard targets?.isEmpty == false || guessTarget else {
            throw ValidationError("--targets parameter is required unless --guess-target is specified")
        }

        parsedTargets = targets ?? []
    }
}
