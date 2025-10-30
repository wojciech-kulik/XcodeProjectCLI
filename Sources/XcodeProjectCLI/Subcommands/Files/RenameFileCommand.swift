import ArgumentParser
import Foundation

struct RenameFileCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rename-file",
        abstract: "Rename a file within the project."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("file"), help: "Path to file.")
    var filePath: String

    @Option(name: .customLong("name"), help: "New name for the file.")
    var name: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        try project.files.renameFile(filePath, newName: name)
        try project.save()

        try FileManager.default.moveItem(
            atPath: filePath.absolutePath,
            toPath: filePath.changeLastComponent(to: name).absolutePath
        )
    }
}
