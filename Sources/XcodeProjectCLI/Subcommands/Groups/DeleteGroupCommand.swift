import ArgumentParser
import Foundation

struct DeleteGroupCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete-group",
        abstract: "Delete a group from the project."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("group"), help: "Path to group.")
    var groupPath: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let groupPath = groupPath.asInputPath

        guard options.projectOnly || groupPath.exists else {
            throw CLIError.groupNotFoundOnDisk(groupPath)
        }

        try project.groups.deleteGroup(groupPath)
        try project.save()

        guard !options.projectOnly else { return }

        try FileManager.default.removeItem(atPath: groupPath.absolutePath)
    }
}
