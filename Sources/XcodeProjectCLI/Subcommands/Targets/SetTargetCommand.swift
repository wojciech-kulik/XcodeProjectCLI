import ArgumentParser
import Foundation
import XcodeProj

struct SetTargetCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "set-target",
        abstract: "Set target for a file or group."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("file"), help: "Full path to file.")
    var filePath: String

    @Option(help: "Comma separated list of target names.")
    var targets: String

    private var parsedTargets: [String] = []

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        try project.targets.setTargets(parsedTargets, for: filePath.asInputPath)
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
