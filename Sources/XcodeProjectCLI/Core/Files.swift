import Foundation
import XcodeProj

final class Files {
    private let project: XcodeProj
    private let groups: Groups
    private let targets: Targets

    init(project: XcodeProj) {
        self.project = project
        self.groups = Groups(project: project)
        self.targets = Targets(project: project)
    }

    func addFile(
        _ filePath: InputPath,
        toTargets targets: [String],
        guessTarget: Bool,
        createGroups: Bool
    ) throws {
        guard filePath.exists else {
            throw CLIError.invalidInput("File \(filePath) does not exist.")
        }

        // Find group
        let groupPath = filePath.directory
        let group = try groups.findGroup(groupPath)

        // Validate group
        if group == nil, !createGroups {
            throw CLIError.invalidInput("Group at path \(groupPath) not found. Use --create-groups to create missing groups.")
        }

        // Create group if needed
        let targetGroup = try group ?? groups.createGroupHierarchy(at: groupPath)

        // Guess targets if needed
        var targets = targets
        if guessTarget, targets.isEmpty {
            let guessedTargets = try self.targets.guessTargetsForGroup(groupPath)

            if guessedTargets.isEmpty {
                print("Error: Could not guess any targets for group at path \(groupPath).")
            } else {
                targets = guessedTargets.map(\.name)
            }
        }

        // Add file to group
        try targetGroup.addFile(
            at: .init(filePath.absolutePath),
            sourceRoot: .init(project.rootDir)
        )

        // Add file to targets
        try self.targets.setTargets(targets, for: filePath)
    }
}
