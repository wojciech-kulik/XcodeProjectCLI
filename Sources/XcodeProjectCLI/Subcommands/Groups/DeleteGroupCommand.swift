import ArgumentParser
import Foundation
import XcodeProject

struct DeleteGroupCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete-group",
        abstract: "Delete a group from the project."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("group"), help: .init("Group path.", valueName: "group-path"))
    var groupPath: String

    func run() throws {
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
