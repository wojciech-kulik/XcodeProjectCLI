import ArgumentParser
import Foundation
import Swift
import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Set Target Command", .serialized)
    final class SetTargetCommandTests: ProjectTests {}
}

extension SerializedSuite.SetTargetCommandTests {
    @Test
    func setTarget_shouldAddFileToSingleTarget() throws {
        var sut = try SetTargetCommand.parse([
            testXcodeprojPath,
            "--file",
            Files.XcodebuildNvimApp.Modules.Main.mainViewModel,
            "--targets",
            "Helpers"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: Files.XcodebuildNvimApp.Modules.Main.mainViewModel)
        #expect(targets == ["Helpers"])
    }

    @Test
    func setTarget_shouldAddFileToMultipleTargets() throws {
        var sut = try SetTargetCommand.parse([
            testXcodeprojPath,
            "--file",
            Files.XcodebuildNvimApp.Modules.Main.mainViewModel,
            "--targets",
            "EmptyTarget,Helpers,XcodebuildNvimAppTests"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: Files.XcodebuildNvimApp.Modules.Main.mainViewModel)
        #expect(targets == [
            "EmptyTarget",
            "Helpers",
            "XcodebuildNvimAppTests"
        ])
    }

    @Test
    func setTarget_shouldReturnError_whenProvidedTargetDoesNotExist() throws {
        let sut = try SetTargetCommand.parse([
            testXcodeprojPath,
            "--file",
            Files.XcodebuildNvimApp.Modules.Main.mainViewModel,
            "--targets",
            "Helpers,NonExistentTarget"
        ])

        do {
            try sut.run()
        } catch let error as CLIError {
            #expect(error.description == "One or more specified targets do not exist in the project.")
        }
    }
}
