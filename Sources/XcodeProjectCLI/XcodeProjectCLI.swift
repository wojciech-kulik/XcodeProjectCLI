//
//  XcodeProjectCLI.swift
//  XcodeProjectCLI
//
//  Created by Wojciech Kulik on 28/10/2025.
//

import ArgumentParser
import XcodeProjectCommands

@main
struct XcodeProjectCLI: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "xcp",
        abstract: "XcodeProjectCLI",
        version: "1.2.0",
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
            ),
            .init(
                name: "Build Settings",
                subcommands: [
                    GetBuildSettingCommand.self,
                    SetBuildSettingCommand.self
                ]
            ),
            .init(
                name: "Assets",
                subcommands: [
                    AddImageAssetCommand.self,
                    AddDataAssetCommand.self,
                    AddColorAssetCommand.self,
                    ListAssetsCommand.self,
                    MoveAssetCommand.self,
                    DeleteAssetCommand.self
                ]
            )
        ]
    )
}
