import Foundation
import XcodeProj

final class Project {
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
        }

        guard let projectPath else {
            throw CLIError.invalidParameter("Xcode project file not found in the current directory.")
        }

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
