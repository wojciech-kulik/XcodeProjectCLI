import ArgumentParser
import Foundation
import XcodeProject

public struct DeleteGroupCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "delete-group",
        abstract: "Delete group."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("group"), help: .init("Group path.", valueName: "group-path"))
    var groupPath: String

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let groupPath = groupPath.asInputPath

        guard options.projectOnly || groupPath.exists else {
            throw XcodeProjectError.groupNotFoundOnDisk(groupPath)
        }

        try project.groups.deleteGroup(groupPath)

        if !options.projectOnly {
            try FileManager.default.removeItem(atPath: groupPath.absolutePath)
        }
        try project.save()
    }
}
