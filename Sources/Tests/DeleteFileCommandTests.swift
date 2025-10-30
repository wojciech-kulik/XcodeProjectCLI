import Testing
import XcodeProj
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Delete File Command", .serialized)
    final class DeleteFileCommandTests: ProjectTests {}
}

extension SerializedSuite.DeleteFileCommandTests {
    @Test
    func deleteFile_shouldDeleteFileFromProjectAndDisk() throws {
        let file = Files.Helpers.GeneralUtils.Subfolder2.stringExtensions
        var sut = try DeleteFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")
        try notExpectFileInProject(file.asInputPath)

        let project = try XcodeProj(path: .init(testXcodeprojPath))

        for target in project.pbxproj.nativeTargets {
            let buildFiles = target.buildPhases
                .flatMap { $0.files ?? [] }
                .compactMap(\.file)

            #expect(buildFiles.allSatisfy { $0.fullPath != file.asInputPath })
        }
    }

    @Test
    func deleteFile_shouldReturnError_whenFileDoesNotExistInProject() throws {
        let file = InputPath(Files.Helpers.notAddedFile, projectRoot: testProjectPath)
        let sut = try DeleteFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath
        ])

        #expect(throws: CLIError.fileNotFoundInProject(file)) {
            try sut.run()
        }
    }

    @Test
    func deleteFile_shouldReturnError_whenFileDoesNotExistOnDisk() throws {
        let file = InputPath("Helpers/NonExistentFile.swift", projectRoot: testProjectPath)
        let sut = try DeleteFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath
        ])

        #expect(throws: CLIError.fileNotFoundOnDisk(file)) {
            try sut.run()
        }
    }
}
