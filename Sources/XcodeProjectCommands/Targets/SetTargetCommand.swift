import ArgumentParser
import XcodeProject

public struct SetTargetCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
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

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw XcodeProjectError.fileNotFoundOnDisk(filePath)
        }

        try project.targets.setTargets(parsedTargets, for: filePath)
        try project.save()
    }

    public mutating func validate() throws {
        let targets = targets.components(separatedBy: ",").filter { !$0.isEmpty }

        guard !targets.isEmpty else {
            throw ValidationError("targets field required")
        }

        parsedTargets = targets
    }
}
