import ArgumentParser
import Foundation

struct DeleteFileCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete-file",
        abstract: "Delete a file from the project."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("file"), help: "Path to file.")
    var filePath: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw CLIError.fileNotFoundOnDisk(filePath)
        }

        try project.files.removeFile(filePath)
        try project.save()

        guard !options.projectOnly else { return }

        try FileManager.default.removeItem(atPath: filePath.absolutePath)
    }
}
