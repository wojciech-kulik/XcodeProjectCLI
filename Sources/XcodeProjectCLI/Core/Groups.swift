import XcodeProj

final class Groups {
    private let project: XcodeProj

    init(project: XcodeProj) {
        self.project = project
    }

    func listAllGroups() throws -> [(group: PBXGroup, path: InputPath)] {
        try project.pbxproj.rootGroup()?
            .allNestedGroups()
            .compactMap {
                guard let path = try $0.fullPath(sourceRoot: project.rootDir) else { return nil }
                return ($0, path.asInputPath)
            } ?? []
    }

    func findGroup(_ groupPath: InputPath) throws -> PBXGroup? {
        try listAllGroups()
            .first { _, enumeratedGroupPath in
                enumeratedGroupPath == groupPath
            }?
            .group
    }

    func createGroupHierarchy(at groupPath: InputPath) throws -> PBXGroup {
        let pathComponents = groupPath.relativePathComponents

        guard let rootGroup = try project.pbxproj.rootGroup() else {
            throw CLIError.unexpectedValue("Root group not found.")
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
