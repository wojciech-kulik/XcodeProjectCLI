import Foundation
import XcodeProj

final class Groups {
    private let project: XcodeProj

    init(project: XcodeProj) {
        self.project = project
    }

    func listAllGroups() throws -> [(group: PBXGroup, fullPath: String)] {
        try project.pbxproj.rootGroup()?
            .listAllGroups()
            .compactMap {
                guard let path = try $0.fullPath(sourceRoot: project.rootDir) else { return nil }
                return ($0, path)
            } ?? []
    }

    func findGroup(_ groupPath: String) throws -> PBXGroup? {
        try listAllGroups()
            .first { _, groupFullPath in
                groupFullPath == groupPath || groupPath == "\(groupFullPath)/"
            }?
            .group
    }

    func createGroupHierarchy(at groupPath: String) throws -> PBXGroup {
        let relativePath = groupPath.replacingOccurrences(of: project.rootDir, with: "").trimmingCharacters(in: ["/"])
        let pathComponents = (relativePath as NSString).pathComponents

        guard let rootGroup = try project.pbxproj.rootGroup() else {
            throw CLIError.invalidParameter("Root group not found.")
        }

        var currentGroup = rootGroup

        for component in pathComponents {
            if let existingGroup = currentGroup.subgroup(named: component) {
                currentGroup = existingGroup
            } else {
                let newGroup = try currentGroup.addGroup(named: component).last!
                currentGroup = newGroup
            }
        }

        return currentGroup
    }
}
