import ArgumentParser
import Foundation

struct MoveGroupCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "move-group",
        abstract: "Move a group to a different location within the project.",
        discussion: "Groups will be automatically merged if a group with the same name already exists at the destination. " +
            "When merging, files and subgroups will be combined.\n\n" +
            "If a file conflict occurs, existing files in the destination group will be preserved, " +
            "and the conflicting source files will be removed. A warning will be displayed to indicate the conflict."
    )

    @OptionGroup
    var options: ProjectOptions

    @Option(name: .customLong("group"), help: "Path to group.")
    var groupPath: String

    @Option(name: .customLong("dest"), help: "Destination path.")
    var destination: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)
        let groupPath = groupPath.asInputPath
        let destination = destination.asInputPath

        guard groupPath.exists else {
            throw CLIError.groupNotFoundOnDisk(groupPath)
        }

        try project.groups.moveGroup(groupPath, to: destination)
        try project.save()

        let newGroupPath = destination.appending(groupPath.lastComponent)

        if FileManager.default.fileExists(atPath: newGroupPath.absolutePath) {
            print("Warning: Merging group '\(groupPath.lastComponent)' into existing group at destination.")
            try mergeDirectories(from: groupPath.absolutePath, to: newGroupPath.absolutePath)
            try FileManager.default.removeItem(atPath: groupPath.absolutePath)
        } else {
            try FileManager.default.createDirectory(
                atPath: destination.absolutePath,
                withIntermediateDirectories: true
            )
            try FileManager.default.moveItem(
                atPath: groupPath.absolutePath,
                toPath: newGroupPath.absolutePath
            )
        }
    }

    private func mergeDirectories(from source: String, to destination: String) throws {
        let fileManager = FileManager.default
        let items = try fileManager.contentsOfDirectory(atPath: source)

        for item in items {
            let sourcePath = (source as NSString).appendingPathComponent(item)
            let destPath = (destination as NSString).appendingPathComponent(item)

            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: sourcePath, isDirectory: &isDirectory)

            if isDirectory.boolValue {
                if fileManager.fileExists(atPath: destPath) {
                    try mergeDirectories(from: sourcePath, to: destPath)
                    try fileManager.removeItem(atPath: sourcePath)
                } else {
                    try fileManager.moveItem(atPath: sourcePath, toPath: destPath)
                }
            } else {
                if fileManager.fileExists(atPath: destPath) {
                    try fileManager.removeItem(atPath: sourcePath)
                    print("Warning: File \(item) already exists at destination. Source file has been removed.")
                } else {
                    try fileManager.moveItem(atPath: sourcePath, toPath: destPath)
                }
            }
        }
    }
}
