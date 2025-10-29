import Foundation
import XcodeProj

final class Project {
    private(set) static var projectRoot = ""

    let targets: Targets
    let groups: Groups
    let files: Files

    private let project: XcodeProj

    init(projectPath: String?) throws {
        var projectPath = projectPath

        if projectPath == nil {
            let fileManager = FileManager.default
            let currentDir = fileManager.currentDirectoryPath
            let contents = try fileManager.contentsOfDirectory(atPath: currentDir)
            projectPath = contents.first { $0.hasSuffix(".xcodeproj") }
            projectPath = InputPath(projectPath ?? "", projectRoot: currentDir).absolutePath
        }

        guard let projectPath else {
            throw CLIError.invalidInput("xcodeproj file not found in the current directory.")
        }

        Self.projectRoot = (projectPath as NSString).deletingLastPathComponent

        self.project = try XcodeProj(pathString: projectPath)
        self.targets = Targets(project: project)
        self.groups = Groups(project: project)
        self.files = Files(project: project)
    }

    func save() throws {
        if let path = project.path {
            try project.write(path: path, override: true)
        }
    }
}
