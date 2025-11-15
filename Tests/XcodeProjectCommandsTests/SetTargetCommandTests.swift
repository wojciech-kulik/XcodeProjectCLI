import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

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

        try validateProject()
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
        try validateProject()
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

        #expect(throws: XcodeProjectError.missingTargets(["NonExistentTarget"])) {
            try sut.run()
        }
    }
}
