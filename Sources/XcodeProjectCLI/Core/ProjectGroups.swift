import Foundation
import XcodeProj

final class ProjectGroups {
    private let project: XcodeProj
    private lazy var projectFiles = ProjectFiles(project: project)

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

        group.name = nil
        group.path = newName
        group.setGroupSourceTree()
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

        if let parent = group.parent as? PBXGroup {
            parent.children.removeAll { $0 === group }
        }

        let destinationGroup = try findGroup(destination) ?? createGroupHierarchy(at: destination)

        if let existingGroup = destinationGroup.subgroup(named: groupPath.lastComponent) {
            try mergeGroups(from: group, into: existingGroup)
            project.pbxproj.delete(object: group)
        } else {
            group.setGroupSourceTree()
            destinationGroup.children.append(group)
        }
    }

    private func mergeGroups(from source: PBXGroup, into target: PBXGroup) throws {
        for child in source.children {
            switch child {
            case let sourceChildGroup as PBXGroup:
                let childName = sourceChildGroup.fullPath?.lastComponent ?? ""

                if let targetChildGroup = target.subgroup(named: childName) {
                    try mergeGroups(from: sourceChildGroup, into: targetChildGroup)
                    project.pbxproj.delete(object: sourceChildGroup)
                } else {
                    sourceChildGroup.parent = target
                    sourceChildGroup.setGroupSourceTree()
                    target.children.append(sourceChildGroup)
                }

            case let fileRef as PBXFileReference:
                let fileName = fileRef.fullPath?.lastComponent ?? ""
                let fileAlreadyExists = target.children.contains { existingChild in
                    if let existingFile = existingChild as? PBXFileReference {
                        return existingFile.fullPath?.lastComponent == fileName
                    }
                    return false
                }

                if fileAlreadyExists {
                    try projectFiles.removeFile(fileRef.fullPath!)
                } else {
                    fileRef.parent = target
                    fileRef.setGroupSourceTree()
                    target.children.append(fileRef)
                }

            default:
                target.children.append(child)
            }
        }

        source.children.removeAll()
    }

    private func removeGroupRecursively(_ group: PBXGroup) throws {
        for child in group.children.reversed() {
            if let childGroup = child as? PBXGroup {
                try removeGroupRecursively(childGroup)
            } else if let fileRef = child as? PBXFileReference {
                try projectFiles.removeFile(fileRef.fullPath!)
            }
        }

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
