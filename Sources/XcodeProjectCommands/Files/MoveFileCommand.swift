import ArgumentParser
import Foundation
import XcodeProject

public struct MoveFileCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "move-file",
        abstract: "Move a file to a different location within the project.",
        discussion: """
          - If the destination file already exists in the project, the operation will fail.
          - The target memberships of the file will be preserved.
        """
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("file"), help: .init("Source file path.", valueName: "file-path"))
    var filePath: String

    @Option(name: .customLong("dest"), help: .init("Destination file path (including file name).", valueName: "file-path"))
    var destination: String

    @Flag(help: "If set, the tool will print the targets the file was added to.")
    var printTargets = false

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let filePath = filePath.asInputPath
        let destination = destination.asInputPath

        guard options.projectOnly || filePath.exists else {
            throw XcodeProjectError.fileNotFoundOnDisk(filePath)
        }

        let targets = try project.files.moveFile(filePath, to: destination)

        if printTargets {
            targets.forEach { print($0) }
        }

        if !options.projectOnly {
            try FileManager.default.moveItem(
                atPath: filePath.absolutePath,
                toPath: destination.absolutePath
            )
        }
        try project.save()
    }
}
