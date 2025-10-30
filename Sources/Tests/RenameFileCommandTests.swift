import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Rename File Command", .serialized)
    final class RenameFileCommandTests: ProjectTests {}
}

extension SerializedSuite.RenameFileCommandTests {
    @Test
    func renameFile_shouldRenameFileInProjectAndOnDisk() throws {
        let file = Files.Helpers.GeneralUtils.Subfolder2.stringExtensions
        let dest = "\(Files.Helpers.GeneralUtils.Subfolder2.group)/StringExt.swift"
        var sut = try RenameFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--name",
            dest.asInputPath.lastComponent
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try notExpectFileInProject(file.asInputPath)
        try expectFileInProject(dest.asInputPath)
        try expectTargets(["Helpers", "XcodebuildNvimApp"], forFile: dest.asInputPath)
    }

    @Test
    func renameFile_shouldReturnError_whenFileDoesNotExistOnDisk() throws {
        let file = InputPath("Helpers/NonExistentFile.swift", projectRoot: testProjectPath)
        let sut = try RenameFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath,
            "--name",
            "NewName.swift"
        ])

        #expect(throws: CLIError.fileNotFoundOnDisk(file)) {
            try sut.run()
        }
    }

    @Test
    func renameFile_shouldReturnError_whenFileDoesNotExistInProject() throws {
        let file = InputPath(Files.Helpers.notAddedFile, projectRoot: testProjectPath)
        let sut = try RenameFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath,
            "--name",
            "NewName.swift"
        ])

        #expect(throws: CLIError.fileNotFoundInProject(file)) {
            try sut.run()
        }
    }
}
