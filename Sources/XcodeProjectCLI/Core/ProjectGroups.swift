import Foundation
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
                currentGroup = try currentGroup.addGroup(named: component).last!
            }
        }

        return currentGroup
    }

    func addGroup(_ groupPath: InputPath) throws {
        if try findGroup(groupPath) != nil {
            print("Warning: Group already exists in the project: \(groupPath)")
            return
        }

        _ = try createGroupHierarchy(at: groupPath)
    }

    func renameGroup(_ groupPath: InputPath, newName: String) throws {
        guard let group = try findGroup(groupPath) else {
            throw CLIError.groupNotFoundInProject(groupPath)
        }

        group.name = newName
        group.path = newName
    }

    func deleteGroup(_ groupPath: InputPath) throws {
        guard let group = try findGroup(groupPath) else {
            throw CLIError.groupNotFoundInProject(groupPath)
        }

        if let parent = group.parent as? PBXGroup {
            parent.children.removeAll { $0 === group }
        }

        try removeGroupRecursively(group)
    }

    func moveGroup(_ groupPath: InputPath, to destination: InputPath) throws {
        guard let group = try findGroup(groupPath) else {
            throw CLIError.groupNotFoundInProject(groupPath)
        }

        // Remove from current parent
        if let parent = group.parent as? PBXGroup {
            parent.children.removeAll { $0 === group }
        }

        if let existingGroup = try findGroup(destination) {
            existingGroup.children.append(group)
            return
        }

        let destinationGroup = try createGroupHierarchy(at: destination)
        destinationGroup.children.append(group)
    }

    private func removeGroupRecursively(_ group: PBXGroup) throws {
        // Remove all children recursively
        for child in group.children {
            if let childGroup = child as? PBXGroup {
                try removeGroupRecursively(childGroup)
            } else if let fileRef = child as? PBXFileReference {
                project.pbxproj.delete(object: fileRef)
            }
        }

        // Remove the group itself
        project.pbxproj.delete(object: group)
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
