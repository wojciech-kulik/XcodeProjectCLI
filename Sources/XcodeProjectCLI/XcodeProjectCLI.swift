//
//  XcodeProjectCLI.swift
//  XcodeProjectCLI
//
//  Created by Wojciech Kulik on 28/10/2025.
//

import ArgumentParser
import Foundation

struct ProjectOptions: ParsableArguments {
    @Argument(help: "xcodeproj path")
    var projectPath: String
}

@main
struct XcodeProjectCLI: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "xcodeproj",
        abstract: "XcodeProjectCLI",
        version: "1.0.0",
        groupedSubcommands: [
            .init(
                name: "Targets",
                subcommands: [
                    ListTargetsCommand.self
                ]
            )
        ]
    )
}
