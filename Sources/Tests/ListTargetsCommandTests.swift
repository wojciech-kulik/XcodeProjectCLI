import ArgumentParser
import Foundation
import Swift
import Testing
@testable import XcodeProjectCLI

@Suite("List Targets Command", .serialized)
final class ListTargetsCommandTests: ProjectTests {
    @Test
    func listTargets() throws {
        let sut = try ListTargetsCommand.parse([testXcodeprojPath])

        let output = try captureOutput {
            try sut.run()
        }

        #expect(output == [
            "EmptyTarget",
            "Helpers",
            "XcodebuildNvimApp",
            "XcodebuildNvimAppTests",
            "XcodebuildNvimAppUITests"
        ].joined(separator: "\n") + "\n")
    }

    @Test
    func listTargetsForFilePath() throws {
        let sut = try ListTargetsCommand.parse([
            testXcodeprojPath,
            "--file",
            Files.Helpers.GeneralUtils.Subfolder2.stringExtensions
        ])

        let output = try captureOutput {
            try sut.run()
        }

        #expect(output == [
            "Helpers",
            "XcodebuildNvimApp"
        ].joined(separator: "\n") + "\n")
    }

    @Test
    func listTargetsForGroupPath_shouldReturnTargetsForFirstSwiftFile() throws {
        let sut = try ListTargetsCommand.parse([testXcodeprojPath, "--group", Files.Helpers.GeneralUtils.Subfolder2.group])

        let output = try captureOutput {
            try sut.run()
        }

        #expect(output == [
            "Helpers",
            "XcodebuildNvimApp"
        ].joined(separator: "\n") + "\n")
    }

    @Test
    func listTargetsForGroupPath2_shouldReturnTargetsForFirstSwiftFile() throws {
        let sut = try ListTargetsCommand.parse([testXcodeprojPath, "--group", Files.Helpers.GeneralUtils.group])

        let output = try captureOutput {
            try sut.run()
        }

        #expect(output == [
            "Helpers",
            "XcodebuildNvimApp",
            "XcodebuildNvimAppTests"
        ].joined(separator: "\n") + "\n")
    }
}
