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
        let currentDir = PathUtils.processWorkingDirectory()

        if projectPath == nil, let currentDir {
            let contents = try FileManager.default.contentsOfDirectory(atPath: currentDir)
            projectPath = contents.first { $0.hasSuffix(".xcodeproj") }
            projectPath = InputPath(projectPath ?? "", projectRoot: currentDir).absolutePath
        } else {
            projectPath = projectPath.flatMap { PathUtils.toAbsolutePath($0) }
        }

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
            try project.writePBXProj(path: path, override: true, outputSettings: .init())
        }
    }
}
