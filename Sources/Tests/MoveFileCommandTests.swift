import ArgumentParser
import Testing
import XcodeProj
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
        #expect(!file.asInputPath.exists)
        #expect(dest.asInputPath.exists)

        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let files = FilesManager(project: project)
        let targets = try targets(forFile: dest)
        #expect(try files.findFile(file.asInputPath) == nil)
        #expect(try files.findFile(dest.asInputPath) != nil)
        #expect(targets == ["XcodebuildNvimApp"])
    }

    @Test
    func moveFile_shouldReturnError_whenFileDoesNotExistOnDisk() throws {
        let file = InputPath("Helpers/NonExistentFile.swift", projectRoot: testProjectPath)
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
        let file = InputPath(Files.Helpers.notAddedFile, projectRoot: testProjectPath)
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
