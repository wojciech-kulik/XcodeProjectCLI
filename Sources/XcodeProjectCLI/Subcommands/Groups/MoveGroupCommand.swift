import ArgumentParser
import Foundation

struct MoveGroupCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "move-group",
        abstract: "Move a group to a different location within the project."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("group"), help: "Path to group.")
    var groupPath: String

    @Option(name: .customLong("dest"), help: "Destination path.")
    var destination: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let groupPath = groupPath.asInputPath
        let destination = destination.asInputPath

        guard groupPath.exists else {
            throw CLIError.groupNotFoundOnDisk(groupPath)
        }

        try project.groups.moveGroup(groupPath, to: destination)
        try project.save()

        let newGroupPath = destination.appending(groupPath.lastComponent)
        try FileManager.default.moveItem(
            atPath: groupPath.absolutePath,
            toPath: newGroupPath.absolutePath
        )
    }
}
