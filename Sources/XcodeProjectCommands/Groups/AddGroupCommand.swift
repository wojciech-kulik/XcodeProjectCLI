import ArgumentParser
import Foundation
import XcodeProject

public struct AddGroupCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "add-group",
        abstract: "Add group."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("group"), help: .init("Group path.", valueName: "group-path"))
    var groupPath: String

    @Flag(help: "If set, the tool will create missing groups in the project structure.")
    var createGroups = false

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let groupPath = groupPath.asInputPath

        try project.groups.addGroup(groupPath)

        guard !options.projectOnly, !groupPath.exists else {
            return try project.save()
        }

        guard createGroups else {
            throw XcodeProjectError.groupNotFoundOnDisk(groupPath)
        }

        try FileManager.default.createDirectory(
            atPath: groupPath.absolutePath,
            withIntermediateDirectories: true
        )
        try project.save()
    }
}
