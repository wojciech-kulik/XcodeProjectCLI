import XcodeProj

#if DEBUG
typealias FilesManager = Files
#endif

final class Files {
    private let project: XcodeProj
    private lazy var groups = Groups(project: project)
    private lazy var targets = Targets(project: project)

    init(project: XcodeProj) {
        self.project = project
    }

    func findFile(_ filePath: InputPath) throws -> PBXFileReference? {
        try project.pbxproj.fileReferences.first {
            let fileRefPath = try $0.fullPath(sourceRoot: project.rootDir)?.asInputPath
            return fileRefPath == filePath
        }
    }

    func addFile(
        _ filePath: InputPath,
        toTargets targets: [String],
        guessTarget: Bool,
        createGroups: Bool
    ) throws {
        guard filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        // Find group
        let groupPath = filePath.directory
        let group = try groups.findGroup(groupPath)

        // Validate group
        if group == nil, !createGroups {
            throw CLIError.groupNotFoundInProject(groupPath)
        }

        // Create group if needed
        let targetGroup = try group ?? groups.createGroupHierarchy(at: groupPath)

        // Guess targets if needed
        var targets = targets
        if guessTarget, targets.isEmpty {
            let guessedTargets = try self.targets.guessTargetsForGroup(groupPath)

            if guessedTargets.isEmpty {
                print("Error: Could not guess any targets for group at path \(groupPath).")
            } else {
                targets = guessedTargets.map(\.name)
            }
        }

        // Add file to group
        try targetGroup.addFile(
            at: .init(filePath.absolutePath),
            sourceRoot: .init(project.rootDir)
        )

        // Add file to targets
        try self.targets.setTargets(targets, for: filePath)
    }

    func removeFile(_ filePath: InputPath) throws {
        guard let fileRef = try findFile(filePath) else {
            throw CLIError.fileNotFoundInProject(filePath)
        }

        // Remove from build phases
        try project.pbxproj.nativeTargets
            .filter { target in
                try target.sourceFiles().contains {
                    try $0.fullPath(sourceRoot: project.rootDir)?.asInputPath == filePath
                }
            }
            .forEach { try removeFile(filePath, from: $0.name) }

        // Remove from parent group
        if let parent = fileRef.parent as? PBXGroup {
            parent.children.removeAll { $0 === fileRef }
        }

        // Remove file reference
        project.pbxproj.delete(object: fileRef)
    }

    func removeFile(_ filePath: InputPath, from target: String) throws {
        guard let target = project.pbxproj.targets(named: target).first else {
            return
        }

        let buildPhase = try target.sourcesBuildPhase()
        buildPhase?.files = try buildPhase?.files?.filter {
            guard let fileRef = $0.file,
                  let fullPath = try fileRef.fullPath(sourceRoot: project.rootDir) else {
                return true
            }
            return fullPath.asInputPath != filePath
        }
    }

    func moveFile(_ filePath: InputPath, to newPath: InputPath) throws {
        try removeFile(filePath)
        try addFile(newPath, toTargets: [], guessTarget: true, createGroups: true)
    }
}
