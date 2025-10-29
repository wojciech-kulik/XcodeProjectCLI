import ArgumentParser
import Foundation

struct MoveFileCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "move-file",
        abstract: "Move a file in the project."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("file"), help: "Path to file.")
    var filePath: String

    @Option(name: .customLong("dest"), help: "Destination path.")
    var destination: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)

        guard filePath.asInputPath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath.asInputPath)
        }

        try FileManager.default.moveItem(atPath: filePath.asInputPath.absolutePath, toPath: destination.asInputPath.absolutePath)

        do {
            try project.files.moveFile(filePath.asInputPath, to: destination.asInputPath)
            try project.save()
        } catch {
            // Rollback file move
            try? FileManager.default.moveItem(
                atPath: destination.asInputPath.absolutePath,
                toPath: filePath.asInputPath.absolutePath
            )
            throw error
        }
    }
}
