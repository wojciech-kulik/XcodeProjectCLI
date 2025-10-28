import XcodeProj

final class Targets {
    let groups: Groups

    private let project: XcodeProj

    init(project: XcodeProj) {
        self.project = project
        self.groups = Groups(project: project)
    }

    func list() -> [PBXTarget] {
        project.pbxproj.nativeTargets.sorted { $0.name < $1.name }
    }

    func list(forFilePath filePath: String) throws -> [PBXTarget] {
        try project.pbxproj.nativeTargets
            .filter { target in
                let files = try target.sourceFiles()
                return try files.contains {
                    try $0.fullPath(sourceRoot: project.rootDir) == filePath
                }
            }
            .sorted { $0.name < $1.name }
    }

    func list(forGroupPath groupPath: String) throws -> [PBXTarget] {
        let group = try groups.findGroup(byFullPath: groupPath)

        guard let group else {
            return []
        }

        let fileToTargetMap = createFileToTargetMap()
        let swiftFiles = try group.children
            .filter { $0.path?.hasSuffix("swift") == true }
            .compactMap { try $0.fullPath(sourceRoot: project.rootDir) }

        for swiftFile in swiftFiles {
            if fileToTargetMap[swiftFile]?.isEmpty == false {
                return fileToTargetMap[swiftFile]!.sorted { $0.name < $1.name }
            }
        }

        return []
    }

    private func createFileToTargetMap() -> [String: [PBXNativeTarget]] {
        var fileToTargetMap: [String: [PBXNativeTarget]] = [:]

        for target in project.pbxproj.nativeTargets {
            let sourceFiles = try? target.sourceFiles()

            for file in sourceFiles ?? [] {
                if let filePath = try? file.fullPath(sourceRoot: project.rootDir), !filePath.isEmpty {
                    fileToTargetMap[filePath, default: []].append(target)
                }
            }
        }

        return fileToTargetMap
    }
}
