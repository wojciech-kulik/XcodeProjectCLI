import ArgumentParser
import Foundation

struct MoveFileCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "move-file",
        abstract: "Move a file to a different location within the project."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("file"), help: "Path to file.")
    var filePath: String

    @Option(name: .customLong("dest"), help: "Destination path.")
    var destination: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let filePath = filePath.asInputPath
        let destination = destination.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        try project.files.moveFile(filePath, to: destination)
        try project.save()

        guard !options.projectOnly else { return }

        try FileManager.default.moveItem(
            atPath: filePath.absolutePath,
            toPath: destination.absolutePath
        )
    }
}
