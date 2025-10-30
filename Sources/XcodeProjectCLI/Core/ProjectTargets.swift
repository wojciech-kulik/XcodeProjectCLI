import XcodeProj

final class ProjectTargets {
    private let project: XcodeProj
    private lazy var projectGroups = ProjectGroups(project: project)
    private lazy var projectFiles = ProjectFiles(project: project)

    init(project: XcodeProj) {
        self.project = project
    }

    func findTargets(for filePath: InputPath) throws -> [PBXTarget] {
        let map = try createFileToTargetMap()

        return map[filePath]?
            .sorted { $0.name < $1.name } ?? []
    }

    func listTargets() -> [PBXTarget] {
        project.pbxproj.nativeTargets
            .sorted { $0.name < $1.name }
    }

    func listTargetsForFile(_ filePath: InputPath) throws -> [PBXTarget] {
        guard projectFiles.findFile(filePath) != nil else {
            throw CLIError.fileNotFoundInProject(filePath)
        }

        return try project.pbxproj.nativeTargets
            .filter { try $0.sourceFiles().contains { $0.fullPath == filePath } }
            .sorted { $0.name < $1.name }
    }

    /// Guesses targets for the given group by looking for Swift files in the group
    /// and finding which targets includes the first found Swift file.
    /// If no Swift files are found in the group, it falls back to the parent group once.
    /// If everything fails, it returns targets matching the first path component of the group.
    func guessTargetsForGroup(
        _ groupPath: InputPath,
        fallbackToParent: Bool = true,
        fileToTargetMap: [InputPath: [PBXNativeTarget]]? = nil
    ) throws -> [PBXTarget] {
        guard let group = try projectGroups.findGroup(groupPath) else {
            throw CLIError.groupNotFoundInProject(groupPath)
        }

        let fileToTargetMap = try fileToTargetMap ?? createFileToTargetMap()
        let swiftFiles = group.children
            .filter { $0.path?.hasSuffix("swift") == true }
            .compactMap(\.fullPath)

        for swiftFile in swiftFiles {
            if let targets = fileToTargetMap[swiftFile], targets.isNotEmpty {
                return targets.sorted { $0.name < $1.name }
            }
        }

        if swiftFiles.isEmpty, fallbackToParent, let parentGroup = group.parent?.fullPath {
            let fallbackResult = try guessTargetsForGroup(parentGroup, fallbackToParent: false, fileToTargetMap: fileToTargetMap)

            if fallbackResult.isNotEmpty {
                return fallbackResult
            }
        }

        let firstGroup = groupPath.relativePathComponents.first ?? ""
        return project.pbxproj.targets(named: firstGroup)
    }

    func setTargets(_ targets: [String], for filePath: InputPath) throws {
        guard let fileReference = projectFiles.findFile(filePath) else {
            throw CLIError.fileNotFoundInProject(filePath)
        }

        let destTargets = targets
            .flatMap { project.pbxproj.targets(named: $0) }

        guard destTargets.count >= targets.count else {
            let diff = Set(targets).subtracting(destTargets.map(\.name))
            throw CLIError.missingTargets(Array(diff))
        }

        for target in try findTargets(for: filePath) {
            if targets.notContains(target.name) {
                try projectFiles.removeFile(filePath, from: target.name)
            }
        }

        for target in destTargets {
            let buildPhase = try target.sourcesBuildPhase()
            _ = try buildPhase?.add(file: fileReference)
        }
    }

    private func createFileToTargetMap() throws -> [InputPath: [PBXNativeTarget]] {
        var fileToTargetMap: [InputPath: [PBXNativeTarget]] = [:]

        for target in project.pbxproj.nativeTargets {
            let sourceFiles = try target.sourceFiles()

            for file in sourceFiles {
                if let filePath = file.fullPath, !filePath.path.isEmpty {
                    fileToTargetMap[filePath, default: []].append(target)
                }
            }
        }

        return fileToTargetMap
    }
}
