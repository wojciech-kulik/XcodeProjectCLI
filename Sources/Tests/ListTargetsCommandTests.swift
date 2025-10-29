import ArgumentParser
import Foundation
import Swift
import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("List Targets Command", .serialized)
    final class ListTargetsCommandTests: ProjectTests {
        // MARK: - List All Targets

        @Test
        func listTargets_shouldReturnTargets() throws {
            var sut = try ListTargetsCommand.parse([testXcodeprojPath])

            let output = try runTest(for: &sut)

            #expect(output == [
                "EmptyTarget",
                "Helpers",
                "XcodebuildNvimApp",
                "XcodebuildNvimAppTests",
                "XcodebuildNvimAppUITests"
            ])
        }

        // MARK: - File Path

        @Test(arguments: 0...1)
        func listTargetsForFilePath_shouldReturnTargets(testCase: Int) throws {
            let testCases = [
                (input: Files.Helpers.GeneralUtils.Subfolder2.stringExtensions, expected: [
                    "Helpers",
                    "XcodebuildNvimApp"
                ]),
                (input: Files.Helpers.GeneralUtils.randomFile, expected: [
                    "Helpers",
                    "XcodebuildNvimApp",
                    "XcodebuildNvimAppTests"
                ])
            ]
            var sut = try ListTargetsCommand.parse([
                testXcodeprojPath,
                "--file",
                testCases[testCase].input
            ])

            let output = try runTest(for: &sut)

            #expect(output == testCases[testCase].expected)
        }

        @Test
        func listTargetsForFilePath_shouldReturnError_whenFileDoesNotExist() throws {
            let sut = try ListTargetsCommand.parse([
                testXcodeprojPath,
                "--file",
                "Helpers/NonExistentFile.swift"
            ])

            do {
                try sut.run()
            } catch let error as CLIError {
                #expect(error.description == "File \(testProjectPath)/Helpers/NonExistentFile.swift does not exist.")
            }
        }

        @Test
        func listTargetsForFilePath_shouldReturnEmptyString_whenFileIsNotAddedToAnyTarget() throws {
            var sut = try ListTargetsCommand.parse([
                testXcodeprojPath,
                "--file",
                Files.XcodebuildNvimApp.Modules.notAddedFile
            ])

            let output = try runTest(for: &sut)

            #expect(output == "")
        }

        // MARK: - Group Path

        @Test(arguments: 0...1)
        func listTargetsForGroupPath_shouldReturnTargetsForFirstSwiftFile(testCase: Int) throws {
            let testCases = [
                (input: Files.Helpers.GeneralUtils.Subfolder2.group, expected: [
                    "Helpers",
                    "XcodebuildNvimApp"
                ]),
                (input: Files.Helpers.GeneralUtils.group, expected: [
                    "Helpers",
                    "XcodebuildNvimApp",
                    "XcodebuildNvimAppTests"
                ])
            ]
            var sut = try ListTargetsCommand.parse([testXcodeprojPath, "--group", testCases[testCase].input])

            let output = try runTest(for: &sut)

            #expect(output == testCases[testCase].expected)
        }

        @Test
        func listTargetsForGroupPath_shouldReturnEmptyString_whenGroupIsNotAddedToAnyTarget() throws {
            var sut = try ListTargetsCommand.parse([
                testXcodeprojPath,
                "--group",
                Files.XcodebuildNvimApp.Modules.NotAdded.group
            ])

            let output = try runTest(for: &sut)

            #expect(output == "")
        }

        @Test
        func listTargetsForGroupPath_shouldReturnError_whenGroupDoesNotExist() throws {
            let sut = try ListTargetsCommand.parse([
                testXcodeprojPath,
                "--group",
                "Helpers/NonExistentGroup"
            ])

            do {
                try sut.run()
            } catch let error as CLIError {
                #expect(error.description == "Group \(testProjectPath)/Helpers/NonExistentGroup does not exist.")
            }
        }
    }
}
