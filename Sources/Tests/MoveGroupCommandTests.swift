import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Move Group Command", .serialized)
    final class MoveGroupCommandTests: ProjectTests {}
}

extension SerializedSuite.MoveGroupCommandTests {
    @Test
    func moveGroup_shouldMoveGroupInProjectAndOnDisk() throws {
        let group = Files.Helpers.GeneralUtils.Subfolder2.group
        let dest = Files.XcodebuildNvimApp.Modules.group
        let newGroupPath = "\(dest)/Subfolder2"
        var sut = try MoveGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group,
            "--dest",
            dest
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try notExpectGroupInProject(group.asInputPath)
        try expectGroupInProject(newGroupPath.asInputPath)
    }

    @Test
    func moveGroup_shouldReturnError_whenGroupDoesNotExistOnDisk() throws {
        let group = "Helpers/NonExistentGroup".asInputPath
        let sut = try MoveGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath,
            "--dest",
            Files.XcodebuildNvimApp.Modules.group
        ])

        #expect(throws: CLIError.groupNotFoundOnDisk(group)) {
            try sut.run()
        }
    }

    @Test
    func moveGroup_shouldReturnError_whenGroupDoesNotExistInProject() throws {
        let group = Files.Helpers.GeneralUtils.NotAdded.group.asInputPath
        let sut = try MoveGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath,
            "--dest",
            Files.XcodebuildNvimApp.Modules.group
        ])

        #expect(throws: CLIError.groupNotFoundInProject(group)) {
            try sut.run()
        }
    }

    @Test
    func moveGroup_shouldMoveGroupToNewLocation_whenDestinationGroupDoesNotExist() throws {
        let group = Files.Helpers.GeneralUtils.Subfolder1.group
        let dest = Files.XcodebuildNvimApp.Modules.NotAdded.group
        let newGroupPath = "\(dest)/Subfolder1"

        // First add the destination group
        var addGroupSut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            dest
        ])
        _ = try runTest(for: &addGroupSut)

        // Now move the group
        var sut = try MoveGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group,
            "--dest",
            dest
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try notExpectGroupInProject(group.asInputPath)
        try expectGroupInProject(newGroupPath.asInputPath)
    }
}
