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
        #expect(!file.asInputPath.exists)

        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let files = FilesManager(project: project)
        #expect(try files.findFile(file.asInputPath) == nil)

        for target in project.pbxproj.nativeTargets {
            let buildFiles = target.buildPhases
                .flatMap { $0.files ?? [] }
                .compactMap(\.file)

            try #expect(buildFiles.allSatisfy {
                try $0.fullPath(sourceRoot: project.rootDir)?.asInputPath != file.asInputPath
            })
        }
    }

    @Test
    func deleteFile_shouldReturnError_whenFileDoesNotExist() throws {
        var sut = try DeleteFileCommand.parse([
            testXcodeprojPath,
            "--file",
            "Helpers/NonExistentFile.swift"
        ])

        do {
            try sut.run()
        } catch let error as CLIError {
            #expect(error.description == "File \(testProjectPath)/Helpers/NonExistentFile.swift not found in the project.")
            return
        }
    }
}
