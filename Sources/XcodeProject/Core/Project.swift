import Foundation
import XcodeProj

public final class Project {
    private(set) static var projectRoot = ""

    public let targets: ProjectTargets
    public let groups: ProjectGroups
    public let files: ProjectFiles

    private let project: XcodeProj

    public init(xcodeProjectPath: String?) throws {
        var projectPath = xcodeProjectPath

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
            throw XcodeProjectError.xcodeProjectNotFound
        }

        Self.projectRoot = (projectPath as NSString).deletingLastPathComponent

        self.project = try XcodeProj(pathString: projectPath)
        self.targets = ProjectTargets(project: project)
        self.groups = ProjectGroups(project: project)
        self.files = ProjectFiles(project: project)
    }

    public func save() throws {
        if let path = project.path {
            try project.write(path: path, override: true)
        }
    }
}
