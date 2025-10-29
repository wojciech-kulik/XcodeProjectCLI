
import ArgumentParser
import Testing
import XcodeProj
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
            dest.asInputPath.fileName
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")
        #expect(!file.asInputPath.exists)
        #expect(dest.asInputPath.exists)

        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let files = FilesManager(project: project)
        let targets = try targets(forFile: dest)
        #expect(try files.findFile(file.asInputPath) == nil)
        #expect(try files.findFile(dest.asInputPath) != nil)
        #expect(targets == ["Helpers", "XcodebuildNvimApp"])
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
