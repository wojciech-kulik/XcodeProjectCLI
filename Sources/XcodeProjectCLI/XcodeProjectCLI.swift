//
//  XcodeProjectCLI.swift
//  XcodeProjectCLI
//
//  Created by Wojciech Kulik on 28/10/2025.
//

import ArgumentParser
import Foundation

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
