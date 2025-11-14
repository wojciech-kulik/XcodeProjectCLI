import Foundation
import XcodeProj

final class Project {
    private(set) static var projectRoot = ""

    let targets: ProjectTargets
    let groups: ProjectGroups
    let files: ProjectFiles

    private let project: XcodeProj

    init(projectPath: String?) throws {
        var projectPath = projectPath

        #if DEBUG
        let currentDir: String? = ProcessInfo.processInfo.environment["PWD"] ?? #filePath
            .components(separatedBy: "/")
            .dropLast(4)
            .joined(separator: "/")
        #else
        let currentDir = ProcessInfo.processInfo.environment["PWD"]
        #endif

        if projectPath == nil, let currentDir {
            let contents = try FileManager.default.contentsOfDirectory(atPath: currentDir)
            projectPath = contents.first { $0.hasSuffix(".xcodeproj") }
            projectPath = InputPath(projectPath ?? "", projectRoot: currentDir).absolutePath
        } else if let projectPathUnwrapped = projectPath, let currentDir, !(projectPathUnwrapped as NSString).isAbsolutePath {
            projectPath = ("\(currentDir)/\(projectPathUnwrapped)" as NSString).standardizingPath
        }

        projectPath = (projectPath as NSString?)?.expandingTildeInPath

        guard let projectPath else {
            throw CLIError.xcodeProjectNotFound
        }

        Self.projectRoot = (projectPath as NSString).deletingLastPathComponent

        self.project = try XcodeProj(pathString: projectPath)
        self.targets = ProjectTargets(project: project)
        self.groups = ProjectGroups(project: project)
        self.files = ProjectFiles(project: project)
    }

    func save() throws {
        if let path = project.path {
            try project.write(path: path, override: true)
        }
    }
}
