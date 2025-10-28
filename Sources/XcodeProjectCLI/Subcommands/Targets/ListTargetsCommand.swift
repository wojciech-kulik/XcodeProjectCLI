import ArgumentParser
import Foundation
import XcodeProj

struct ListTargetsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list-targets",
        abstract: "List project targets."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(help: "Find targets for a specific file")
    var filePath: String?

    @Option(help: "Find targets for a specific group")
    var groupPath: String?

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let targets: [PBXTarget]

        if let groupPath {
            targets = try project.targets.listTargets(forGroupPath: groupPath)
        } else if let filePath {
            targets = try project.targets.listTargets(forFilePath: filePath)
        } else {
            targets = project.targets.listTargets()
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
