import XcodeProj

public final class ProjectTargets {
    private let project: XcodeProj
    private lazy var projectGroups = ProjectGroups(project: project)
    private lazy var projectFiles = ProjectFiles(project: project)

    init(project: XcodeProj) {
        self.project = project
    }

    public init(xcodeProjectPath: String) throws {
        self.project = try XcodeProj(pathString: xcodeProjectPath)
    }

    public func getBuildSettingForTarget(
        _ targetName: String,
        config: String?,
        key: String
    ) throws -> String? {
        guard let target = project.pbxproj.targets(named: targetName).first else {
            throw XcodeProjectError.missingTargets([targetName])
        }

        let buildConfig: XCBuildConfiguration?

        if let config {
            guard let configFound = target.buildConfigurationList?.buildConfigurations.first(where: { $0.name == config }) else {
                throw XcodeProjectError.buildConfigurationNotFound(config)
            }
            buildConfig = configFound
        } else {
            buildConfig = target.buildConfigurationList?.buildConfigurations.first
        }

        if let array = buildConfig?.buildSettings[key] as? [String] {
            return array.joined(separator: "\n")
        } else {
            return buildConfig?.buildSettings[key] as? String
        }
    }

    public func setBuildSettingsForTarget(
        _ targets: [String],
        configs: [String],
        settings: [String: String],
        append: Bool
    ) throws {
        let nativeTargets = try targets.flatMap {
            let result = project.pbxproj.targets(named: $0)
            if result.isEmpty {
                throw XcodeProjectError.missingTargets([$0])
            }

            return result
        }

        for target in nativeTargets {
            target.buildConfigurationList?.buildConfigurations
                .filter { configs.isEmpty || configs.contains($0.name) }
                .forEach { config in
                    for (key, value) in settings {
                        if append, let existingValue = config.buildSettings[key] as? String {
                            config.buildSettings[key] = existingValue + " " + value
                        } else if let existingValue = config.buildSettings[key] as? [Any] {
                            if append {
                                config.buildSettings[key] = existingValue + [value]
                            } else {
                                config.buildSettings[key] = [value]
                            }
                        } else {
                            config.buildSettings[key] = value
                        }
                    }
                }
        }
    }

    public func findTargets(for filePath: InputPath) throws -> [PBXTarget] {
        let map = try createFileToTargetMap()

        return map[filePath]?
            .sorted { $0.name < $1.name } ?? []
    }

    public func listTargets() -> [PBXTarget] {
        project.pbxproj.nativeTargets
            .sorted { $0.name < $1.name }
    }

    public func listTargetsForFile(_ filePath: InputPath) throws -> [PBXTarget] {
        guard projectFiles.findFile(filePath) != nil else {
            throw XcodeProjectError.fileNotFoundInProject(filePath)
        }

        return try project.pbxproj.nativeTargets
            .filter { try $0.sourceFiles().contains { $0.fullPath == filePath } }
            .sorted { $0.name < $1.name }
    }

    /// Guesses targets for the given group by looking for Swift files in the group
    /// and finding which targets includes the first found Swift file.
    /// If no Swift files are found in the group, it falls back to the parent group once.
    /// If everything fails, it returns targets matching the first path component of the group.
    public func guessTargetsForGroup(
        _ groupPath: InputPath,
        fallbackToParent: Bool = true,
        fileToTargetMap: [InputPath: [PBXNativeTarget]]? = nil
    ) throws -> [PBXTarget] {
        guard let group = try projectGroups.findGroup(groupPath) else {
            throw XcodeProjectError.groupNotFoundInProject(groupPath)
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

        let firstGroup = groupPath.firstRelativeComponent
        return project.pbxproj.targets(named: firstGroup)
    }

    public func setTargets(_ targets: [String], for filePath: InputPath) throws {
        guard let fileReference = projectFiles.findFile(filePath) else {
            throw XcodeProjectError.fileNotFoundInProject(filePath)
        }

        let destTargets = targets
            .flatMap { project.pbxproj.targets(named: $0) }

        guard destTargets.count >= targets.count else {
            let diff = Set(targets).subtracting(destTargets.map(\.name))
            throw XcodeProjectError.missingTargets(Array(diff))
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
