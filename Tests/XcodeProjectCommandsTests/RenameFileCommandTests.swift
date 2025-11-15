import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

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
        try validateProject()
    }

    @Test
    func renameFile_shouldReturnError_whenFileDoesNotExistOnDisk() throws {
        let file = "Helpers/NonExistentFile.swift".asInputPath
        let sut = try RenameFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath,
            "--name",
            "NewName.swift"
        ])

        #expect(throws: XcodeProjectError.fileNotFoundOnDisk(file)) {
            try sut.run()
        }
    }

    @Test
    func renameFile_shouldReturnError_whenFileDoesNotExistInProject() throws {
        let file = Files.Helpers.notAddedFile.asInputPath
        let sut = try RenameFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath,
            "--name",
            "NewName.swift"
        ])

        #expect(throws: XcodeProjectError.fileNotFoundInProject(file)) {
            try sut.run()
        }
    }
}
