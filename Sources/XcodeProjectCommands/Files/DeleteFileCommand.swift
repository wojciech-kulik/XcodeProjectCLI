import ArgumentParser
import Foundation
import XcodeProject

public struct DeleteFileCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "delete-file",
        abstract: "Delete file."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("file"), help: .init("File path.", valueName: "file-path"))
    var filePath: String

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw XcodeProjectError.fileNotFoundOnDisk(filePath)
        }

        try project.files.removeFile(filePath)

        if !options.projectOnly {
            try FileManager.default.removeItem(atPath: filePath.absolutePath)
        }
        try project.save()
    }
}
