//
//  XcodeProjectCLI.swift
//  XcodeProjectCLI
//
//  Created by Wojciech Kulik on 28/10/2025.
//

import ArgumentParser
import Foundation

struct ProjectOptions: ParsableArguments {
    @Argument(help: .init(
        "xcodeproj full path, if not provided will search in the current directory",
        valueName: "xcodeproj"
    ))
    var projectPath: String?
}

@main
struct XcodeProjectCLI: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "xcodeproj",
        abstract: "XcodeProjectCLI",
        version: "0.1.0",
        groupedSubcommands: [
            .init(
                name: "Target",
                subcommands: [
                    ListTargetsCommand.self,
                    SetTargetCommand.self
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
