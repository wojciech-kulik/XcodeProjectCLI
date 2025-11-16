import ArgumentParser
import Foundation
import XcodeProject

public struct RenameFileCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "rename-file",
        abstract: "Rename a file."
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("file"), help: .init("File path.", valueName: "file-path"))
    var filePath: String

    @Option(name: .customLong("name"), help: "New name for the file.")
    var name: String

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let filePath = filePath.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw XcodeProjectError.fileNotFoundOnDisk(filePath)
        }

        try project.files.renameFile(filePath, newName: name)

        if !options.projectOnly {
            try FileManager.default.moveItem(
                atPath: filePath.absolutePath,
                toPath: filePath.changeLastComponent(to: name).absolutePath
            )
        }
        try project.save()
    }
}
