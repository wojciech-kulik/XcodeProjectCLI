import Foundation
import XcodeProj

final class Targets {
    let groups: Groups

    private let project: XcodeProj

    init(project: XcodeProj) {
        self.project = project
        self.groups = Groups(project: project)
    }

    func listTargets() -> [PBXTarget] {
        project.pbxproj.nativeTargets.sorted { $0.name < $1.name }
    }

    func listTargetsForFile(_ filePath: String) throws -> [PBXTarget] {
        try project.pbxproj.nativeTargets
            .filter { target in
                let files = try target.sourceFiles()
                return try files.contains {
                    try $0.fullPath(sourceRoot: project.rootDir) == filePath
                }
            }
            .sorted { $0.name < $1.name }
    }

    func listTargetsForGroup(_ groupPath: String) throws -> [PBXTarget] {
        let group = try groups.findGroup(byFullPath: groupPath)

        guard let group else {
            return []
        }

        let fileToTargetMap = try createFileToTargetMap()
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

    func setTargets(_ targets: [String], for filePath: String) throws {
        let destTargets = targets.flatMap {
            project.pbxproj.targets(named: $0)
        }

        guard destTargets.count == targets.count else {
            throw CLIError.invalidParameter("One or more specified targets do not exist in the project.")
        }

        let fileToTargetMap = try createFileToTargetMap()

        for target in fileToTargetMap[filePath] ?? [] {
            if !targets.contains(target.name) {
                try removeFile(filePath, from: target.name)
            }
        }

        let fileReference = try project.pbxproj.fileReferences
            .first { try $0.fullPath(sourceRoot: project.rootDir) == filePath }

        guard let fileReference else {
            return
        }

        for target in destTargets {
            let buildPhase = try target.sourcesBuildPhase()
            _ = try buildPhase?.add(file: fileReference)
        }
    }

    private func removeFile(_ filePath: String, from target: String) throws {
        guard let target = project.pbxproj.targets(named: target).first else {
            return
        }

        let buildPhase = try target.sourcesBuildPhase()
        buildPhase?.files = try buildPhase?.files?.filter {
            guard let fileRef = $0.file else {
                return true
            }
            let fullPath = try fileRef.fullPath(sourceRoot: project.rootDir)
            return fullPath != filePath
        }
    }

    private func createFileToTargetMap() throws -> [String: [PBXNativeTarget]] {
        var fileToTargetMap: [String: [PBXNativeTarget]] = [:]

        for target in project.pbxproj.nativeTargets {
            let sourceFiles = try target.sourceFiles()

            for file in sourceFiles {
                if let filePath = try file.fullPath(sourceRoot: project.rootDir), !filePath.isEmpty {
                    fileToTargetMap[filePath, default: []].append(target)
                }
            }
        }

        return fileToTargetMap
    }
}
