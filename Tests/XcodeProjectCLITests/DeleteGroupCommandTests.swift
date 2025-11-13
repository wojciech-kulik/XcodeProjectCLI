import Testing
import XcodeProj
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Delete Group Command", .serialized)
    final class DeleteGroupCommandTests: ProjectTests {}
}

extension SerializedSuite.DeleteGroupCommandTests {
    @Test
    func deleteGroup_shouldDeleteGroupFromProjectAndDisk() throws {
        let group = Files.Helpers.GeneralUtils.Subfolder2.group
        var sut = try DeleteGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")
        try notExpectGroupInProject(group.asInputPath)
        try validateProject()
    }

    @Test
    func deleteGroup_shouldDeleteNestedGroupsRecursively() throws {
        let group = Files.Helpers.GeneralUtils.group
        var sut = try DeleteGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try notExpectGroupInProject(group.asInputPath)
        try notExpectGroupInProject(Files.Helpers.GeneralUtils.Subfolder1.group.asInputPath)
        try notExpectGroupInProject(Files.Helpers.GeneralUtils.Subfolder2.group.asInputPath)

        try notExpectFileInProject(Files.Helpers.GeneralUtils.randomFile.asInputPath)
        try notExpectFileInProject(Files.Helpers.GeneralUtils.Subfolder1.customFile.asInputPath)
        try notExpectFileInProject(Files.Helpers.GeneralUtils.Subfolder2.stringExtensions.asInputPath)

        try validateProject()
    }

    @Test
    func deleteGroup_shouldReturnError_whenGroupDoesNotExistInProject() throws {
        let group = Files.Helpers.GeneralUtils.NotAdded.group.asInputPath
        let sut = try DeleteGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath
        ])

        #expect(throws: CLIError.groupNotFoundInProject(group)) {
            try sut.run()
        }
    }

    @Test
    func deleteGroup_shouldReturnError_whenGroupDoesNotExistOnDisk() throws {
        let group = "Helpers/NonExistentGroup".asInputPath
        let sut = try DeleteGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath
        ])

        #expect(throws: CLIError.groupNotFoundOnDisk(group)) {
            try sut.run()
        }
    }
}
