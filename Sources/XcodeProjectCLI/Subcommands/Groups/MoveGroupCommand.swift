import ArgumentParser
import Foundation
import XcodeProject

struct MoveGroupCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "move-group",
        abstract: "Move a group to a different location within the project.",
        discussion: """
          - This command does not allow to move and rename the group at the same time.
          - Groups will be automatically merged if another group with the same name already exists at the destination.
          - When merging, files and subgroups will be combined.
          - If a file conflict occurs, existing files in the destination group will be preserved.
          - The conflicting source files will be moved with a ".bak" suffix. 
          - A warning will be displayed to indicate the conflict.
        """
    )

    @OptionGroup
    var options: ProjectWriteOptions

    @Option(name: .customLong("group"), help: .init("Source group path.", valueName: "group-path"))
    var groupPath: String

    @Option(
        name: .customLong("dest"),
        help: .init(
            "Destination group path. The whole source group will be moved into this path.",
            valueName: "group-path"
        )
    )
    var destination: String

    func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)
        let groupPath = groupPath.asInputPath
        let destination = destination.asInputPath

        guard options.projectOnly || groupPath.exists else {
            throw XcodeProjectError.groupNotFoundOnDisk(groupPath)
        }

        try project.groups.moveGroup(groupPath, to: destination)

        guard !options.projectOnly else { return try project.save() }

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

        try project.save()
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
                    let bakPath = destPath.asInputPath.changeLastComponent(
                        to: "\(destPath.asInputPath.lastComponent).bak"
                    ).absolutePath
                    try fileManager.moveItem(atPath: sourcePath, toPath: bakPath)
                    print("Warning: File \(item) already exists at destination. Backup created at \(bakPath).")
                } else {
                    try fileManager.moveItem(atPath: sourcePath, toPath: destPath)
                }
            }
        }
    }
}
