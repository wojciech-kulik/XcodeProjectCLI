import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Rename Group Command", .serialized)
    final class RenameGroupCommandTests: ProjectTests {}
}

extension SerializedSuite.RenameGroupCommandTests {
    @Test
    func renameGroup_shouldRenameGroupInProjectAndOnDisk() throws {
        let group = Files.Helpers.GeneralUtils.Subfolder2.group
        let newGroupPath = "\(Files.Helpers.GeneralUtils.group)/Subfolder2Renamed"
        var sut = try RenameGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group,
            "--name",
            "Subfolder2Renamed"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try notExpectGroupInProject(group.asInputPath)
        try expectGroupInProject(newGroupPath.asInputPath)
        try validateProject()
    }

    @Test
    func renameGroup_shouldReturnError_whenGroupDoesNotExistOnDisk() throws {
        let group = "Helpers/NonExistentGroup".asInputPath
        let sut = try RenameGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath,
            "--name",
            "NewName"
        ])

        #expect(throws: CLIError.groupNotFoundOnDisk(group)) {
            try sut.run()
        }
    }

    @Test
    func renameGroup_shouldReturnError_whenGroupDoesNotExistInProject() throws {
        let group = Files.Helpers.GeneralUtils.NotAdded.group.asInputPath
        let sut = try RenameGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath,
            "--name",
            "NewName"
        ])

        #expect(throws: CLIError.groupNotFoundInProject(group)) {
            try sut.run()
        }
    }
}
