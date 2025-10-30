import ArgumentParser
import Foundation

struct RenameGroupCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rename-group",
        abstract: "Rename a group within the project."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("group"), help: "Path to group.")
    var groupPath: String

    @Option(name: .customLong("name"), help: "New name for the group.")
    var name: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let groupPath = groupPath.asInputPath

        guard options.projectOnly || groupPath.exists else {
            throw CLIError.groupNotFoundOnDisk(groupPath)
        }

        try project.groups.renameGroup(groupPath, newName: name)
        try project.save()

        guard !options.projectOnly else { return }

        try FileManager.default.moveItem(
            atPath: groupPath.absolutePath,
            toPath: groupPath.changeLastComponent(to: name).absolutePath
        )
    }
}
