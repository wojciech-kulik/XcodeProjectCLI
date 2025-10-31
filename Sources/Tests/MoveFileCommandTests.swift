import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Move File Command", .serialized)
    final class MoveFileCommandTests: ProjectTests {}
}

extension SerializedSuite.MoveFileCommandTests {
    @Test(arguments: [
        "\(Files.XcodebuildNvimApp.Modules.Main.group)/StringExt.swift",
        "\(Files.Helpers.GeneralUtils.NotAdded.group)/StringExt.swift"
    ])
    func moveFile_shouldMoveAndRenameFileInProjectAndOnDisk_andShouldNotChangeTarget(dest: String) throws {
        let file = Files.Helpers.GeneralUtils.Subfolder2.stringExtensions
        var sut = try MoveFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--dest",
            dest
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try notExpectFileInProject(file.asInputPath)
        try expectFileInProject(dest.asInputPath)
        try expectTargets(["Helpers", "XcodebuildNvimApp"], forFile: dest.asInputPath)
        try validateProject()
    }

    @Test
    func moveFile_shouldReturnError_whenFileDoesNotExistOnDisk() throws {
        let file = "Helpers/NonExistentFile.swift".asInputPath
        let sut = try MoveFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath,
            "--dest",
            "Helpers/Dest.swift"
        ])

        #expect(throws: CLIError.fileNotFoundOnDisk(file)) {
            try sut.run()
        }
    }

    @Test
    func moveFile_shouldReturnError_whenFileDoesNotExistInProject() throws {
        let file = Files.Helpers.notAddedFile.asInputPath
        let sut = try MoveFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath,
            "--dest",
            "Helpers/Dest.swift"
        ])

        #expect(throws: CLIError.fileNotFoundInProject(file)) {
            try sut.run()
        }
    }
}
