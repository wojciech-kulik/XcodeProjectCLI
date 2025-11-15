import ArgumentParser
import Foundation
import XcodeProject

public struct RenameGroupCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "rename-group",
        abstract: "Rename a group within the project."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("group"), help: .init("Group path.", valueName: "group-path"))
    var groupPath: String

    @Option(name: .customLong("name"), help: "New name for the group.")
    var name: String

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let groupPath = groupPath.asInputPath

        guard options.projectOnly || groupPath.exists else {
            throw XcodeProjectError.groupNotFoundOnDisk(groupPath)
        }

        try project.groups.renameGroup(groupPath, newName: name)

        if !options.projectOnly {
            try FileManager.default.moveItem(
                atPath: groupPath.absolutePath,
                toPath: groupPath.changeLastComponent(to: name).absolutePath
            )
        }
        try project.save()
    }
}
