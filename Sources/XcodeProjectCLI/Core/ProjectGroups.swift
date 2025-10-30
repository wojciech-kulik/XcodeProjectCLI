import XcodeProj

final class ProjectGroups {
    private let project: XcodeProj

    init(project: XcodeProj) {
        self.project = project
    }

    func findGroup(_ groupPath: InputPath) throws -> PBXGroup? {
        try listAllGroups()
            .first { $1 == groupPath }?
            .group
    }

    func createGroupHierarchy(at groupPath: InputPath) throws -> PBXGroup {
        guard let rootGroup = try project.pbxproj.rootGroup() else {
            throw CLIError.rootGroupNotFound
        }

        let pathComponents = groupPath.relativePathComponents
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

    private func listAllGroups() throws -> [(group: PBXGroup, path: InputPath)] {
        guard let rootGroup = try project.pbxproj.rootGroup() else {
            throw CLIError.rootGroupNotFound
        }

        return try rootGroup
            .allNestedGroups()
            .compactMap {
                guard let path = $0.fullPath else { return nil }
                return ($0, path)
            }
    }
}
