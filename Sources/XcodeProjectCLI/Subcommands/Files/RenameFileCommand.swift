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

        guard filePath.asInputPath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath.asInputPath)
        }

        try project.files.renameFile(filePath.asInputPath, newName: name)

        let destination = (filePath.asInputPath.directory.absolutePath as NSString).appendingPathComponent(name)
        try FileManager.default.moveItem(
            atPath: filePath.asInputPath.absolutePath,
            toPath: destination.asInputPath.absolutePath
        )

        try project.save()
    }
}
