import Foundation
import XcodeProj

public final class ProjectFiles {
    private let project: XcodeProj
    private lazy var projectGroups = ProjectGroups(project: project)
    private lazy var projectTargets = ProjectTargets(project: project)

    init(project: XcodeProj) {
        self.project = project
    }

    public init(xcodeProjectPath: String) throws {
        self.project = try XcodeProj(pathString: xcodeProjectPath)
    }

    public func findFile(_ filePath: InputPath) -> PBXFileReference? {
        project.pbxproj.fileReferences
            .first { $0.fullPath == filePath }
    }

    @discardableResult
    public func addFile(
        _ filePath: InputPath,
        toTargets targets: [String],
        guessTarget: Bool,
        createGroups: Bool
    ) throws -> [TargetName] {
        // Find group
        let groupPath = filePath.directory
        let group = try projectGroups.findGroup(groupPath)

        // Validate group
        if group == nil, !createGroups {
            throw XcodeProjectError.groupNotFoundInProject(groupPath)
        }

        // Create group if needed
        let targetGroup = try group ?? projectGroups.createGroupHierarchy(at: groupPath)

        // Guess targets if needed
        var targets = targets
        if guessTarget, targets.isEmpty {
            let guessedTargets = try projectTargets.guessTargetsForGroup(groupPath)

            if guessedTargets.isEmpty {
                print("Warning: Could not guess any targets for the file: \(filePath).")
            } else {
                targets = guessedTargets.map(\.name)
            }
        }

        // Add file to group
        try targetGroup.addFile(
            at: .init(filePath.absolutePath),
            sourceRoot: .init(project.rootDir),
            validatePresence: false
        )

        // Add file to targets
        try projectTargets.setTargets(targets, for: filePath)

        return targets
    }

    public func removeFile(_ filePath: InputPath) throws {
        guard let fileRef = findFile(filePath) else {
            throw XcodeProjectError.fileNotFoundInProject(filePath)
        }

        // Remove from phases: "Compile sources" and "Copy Bundle Resources"
        try project.pbxproj.nativeTargets
            .filter { target in
                try target.allFiles().contains { $0.fullPath == filePath }
            }
            .forEach { try removeFile(filePath, from: $0.name) }

        // Remove from parent group
        if let parent = fileRef.parent as? PBXGroup {
            parent.children.removeAll { $0 === fileRef }
        }

        // Remove file reference
        project.pbxproj.delete(object: fileRef)
    }

    public func removeFile(_ filePath: InputPath, from target: String) throws {
        guard let target = project.pbxproj.targets(named: target).first else {
            return
        }

        try target.sourcesBuildPhase()?.files?
            .removeAll { $0.file?.fullPath == filePath }
        try target.resourcesBuildPhase()?.files?
            .removeAll { $0.file?.fullPath == filePath }
    }

    @discardableResult
    public func moveFile(_ filePath: InputPath, to newPath: InputPath) throws -> [TargetName] {
        let targets = try projectTargets.findTargets(for: filePath)

        guard let fileRef = findFile(filePath) else {
            throw XcodeProjectError.fileNotFoundInProject(filePath)
        }

        // Find or create destination group
        let destGroup = try projectGroups.findGroup(newPath.directory) ??
            projectGroups.createGroupHierarchy(at: newPath.directory)

        // Move file reference to new group
        if let parent = fileRef.parent as? PBXGroup {
            parent.children.removeAll { $0 === fileRef }
        }
        destGroup.children.append(fileRef)

        // Rename if needed
        if filePath.lastComponent != newPath.lastComponent {
            fileRef.name = nil
            fileRef.path = newPath.lastComponent
            fileRef.setGroupSourceTree()
        }

        return targets.map(\.name)
    }

    public func renameFile(_ filePath: InputPath, newName: String) throws {
        guard let file = findFile(filePath) else {
            throw XcodeProjectError.fileNotFoundInProject(filePath)
        }

        file.name = nil
        file.path = newName
        file.setGroupSourceTree()
    }
}
