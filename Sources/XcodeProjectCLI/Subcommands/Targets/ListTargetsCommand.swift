import ArgumentParser
import Foundation
import XcodeProj

struct ProjectOptions: ParsableArguments {
    @Argument(help: "xcodeproj path")
    var projectPath: String

    var projectDir: String {
        (projectPath as NSString).deletingLastPathComponent
    }
}

struct ListTargetsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list-targets",
        abstract: "List targets"
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(help: "List targets for a specific file")
    var filePath: String?

    @Option(help: "List targets for a specific group")
    var groupPath: String?

    func run() throws {
        let project = try XcodeProj(pathString: options.projectPath)
        var targets = project.pbxproj.nativeTargets

        if let groupPath {
            // TODO:
        } else if let filePath {
            targets = try targets.filter { target in
                let files = try target.sourceFiles()
                return try files.contains {
                    try $0.fullPath(sourceRoot: options.projectDir) == filePath
                }
            }
        }

        for target in targets.map(\.name) {
            print(target)
        }
    }
}
