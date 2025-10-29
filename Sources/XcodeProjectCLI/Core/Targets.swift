import XcodeProj

final class Targets {
    private let project: XcodeProj
    private lazy var groups = Groups(project: project)
    private lazy var files = Files(project: project)

    init(project: XcodeProj) {
        self.project = project
    }

    func listTargets() -> [PBXTarget] {
        project.pbxproj.nativeTargets.sorted { $0.name < $1.name }
    }

    func listTargetsForFile(_ filePath: InputPath) throws -> [PBXTarget] {
        guard filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        return try project.pbxproj.nativeTargets
            .filter { target in
                let files = try target.sourceFiles()
                return try files.contains {
                    try $0.fullPath(sourceRoot: project.rootDir)?.asInputPath == filePath
                }
            }
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
        guard groupPath.exists else {
            throw CLIError.groupNotFoundOnDisk(groupPath)
        }

        let group = try groups.findGroup(groupPath)

        guard let group else {
            return []
        }

        let fileToTargetMap = try fileToTargetMap ?? createFileToTargetMap()
        let swiftFiles = try group.children
            .filter { $0.path?.hasSuffix("swift") == true }
            .compactMap { try $0.fullPath(sourceRoot: project.rootDir)?.asInputPath }

        if fallbackToParent, swiftFiles.isEmpty,
           let parentGroup = try group.parent?.fullPath(sourceRoot: project.rootDir)?.asInputPath {
            let fallbackResult = try guessTargetsForGroup(parentGroup, fallbackToParent: false, fileToTargetMap: fileToTargetMap)

            if !fallbackResult.isEmpty {
                return fallbackResult
            } else {
                // Fallback to first path component targets
            }
        }

        for swiftFile in swiftFiles {
            if fileToTargetMap[swiftFile]?.isEmpty == false {
                return fileToTargetMap[swiftFile]!.sorted { $0.name < $1.name }
            }
        }

        let firstGroup = groupPath.relativePathComponents.first ?? ""
        return project.pbxproj.targets(named: firstGroup)
    }

    func setTargets(_ targets: [String], for filePath: InputPath) throws {
        guard filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        let destTargets = targets.flatMap {
            project.pbxproj.targets(named: $0)
        }

        guard destTargets.count == targets.count else {
            let diff = Set(targets).subtracting(destTargets.map(\.name))
            throw CLIError.missingTargets(Array(diff))
        }

        let fileToTargetMap = try createFileToTargetMap()

        for target in fileToTargetMap[filePath] ?? [] {
            if !targets.contains(target.name) {
                try files.removeFile(filePath, from: target.name)
            }
        }

        let fileReference = try files.findFile(filePath)

        guard let fileReference else {
            throw CLIError.fileNotFoundInProject(filePath)
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
                if let filePath = try file.fullPath(sourceRoot: project.rootDir), !filePath.isEmpty {
                    fileToTargetMap[filePath.asInputPath, default: []].append(target)
                }
            }
        }

        return fileToTargetMap
    }
}
