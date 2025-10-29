import ArgumentParser
import Foundation

struct DeleteFileCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete-file",
        abstract: "Delete a file from the project."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("file"), help: "Path to file.")
    var filePath: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        try project.files.removeFile(filePath.asInputPath)
        try project.save()
        try FileManager.default.removeItem(atPath: filePath.asInputPath.absolutePath)
    }
}
