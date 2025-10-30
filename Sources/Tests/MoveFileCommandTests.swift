import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Move File Command", .serialized)
    final class MoveFileCommandTests: ProjectTests {}
}

extension SerializedSuite.MoveFileCommandTests {
    @Test
    func moveFile_shouldMoveFileInProjectAndOnDisk() throws {
        let file = Files.Helpers.GeneralUtils.Subfolder2.stringExtensions
        let dest = "\(Files.XcodebuildNvimApp.Modules.Main.group)/StringExt.swift"
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
        try expectTargets(["XcodebuildNvimApp"], forFile: dest.asInputPath)
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
