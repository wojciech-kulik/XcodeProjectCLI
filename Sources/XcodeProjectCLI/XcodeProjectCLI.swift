//
//  XcodeProjectCLI.swift
//  XcodeProjectCLI
//
//  Created by Wojciech Kulik on 28/10/2025.
//

import ArgumentParser
import Foundation

struct ProjectWriteOptions: ParsableArguments {
    @Argument(help: .init(
        "xcodeproj full path, if not provided will search in the current directory",
        valueName: "xcode-project"
    ))
    var projectPath: String?

    @Flag(
        help: "If set, only update the project file without performing any disk operations (creating, moving, deleting files/folders)."
    )
    var projectOnly = false
}

struct ProjectReadOptions: ParsableArguments {
    @Argument(help: .init(
        "xcodeproj full path, if not provided will search in the current directory",
        valueName: "xcode-project"
    ))
    var projectPath: String?
}

@main
struct XcodeProjectCLI: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "xcp",
        abstract: "XcodeProjectCLI",
        version: "0.9.1",
        groupedSubcommands: [
            .init(
                name: "Target",
                subcommands: [
                    ListTargetsCommand.self,
                    SetTargetCommand.self
                ]
            ),
            .init(
                name: "Group",
                subcommands: [
                    AddGroupCommand.self,
                    DeleteGroupCommand.self,
                    MoveGroupCommand.self,
                    RenameGroupCommand.self
                ]
            ),
            .init(
                name: "File",
                subcommands: [
                    AddFileCommand.self,
                    DeleteFileCommand.self,
                    MoveFileCommand.self,
                    RenameFileCommand.self
                ]
            )
        ]
    )
}
