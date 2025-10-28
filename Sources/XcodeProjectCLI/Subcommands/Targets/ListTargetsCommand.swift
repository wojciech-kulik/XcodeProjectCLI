import ArgumentParser
import Foundation
import XcodeProj

struct ListTargetsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list-targets",
        abstract: "List targets"
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(help: "Find targets for a specific file")
    var filePath: String?

    @Option(help: "Find targets for a specific group")
    var groupPath: String?

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        var targets: [PBXTarget] = []

        if let groupPath {
            targets = try project.targets.list(forGroupPath: groupPath)
        } else if let filePath {
            targets = try project.targets.list(forFilePath: filePath)
        } else {
            targets = project.targets.list()
        }

        for target in targets {
            print(target.name)
        }
    }
}
