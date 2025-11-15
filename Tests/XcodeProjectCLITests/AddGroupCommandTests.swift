import Testing
@testable import XcodeProject
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Add Group Command", .serialized)
    final class AddGroupCommandTests: ProjectTests {}
}

extension SerializedSuite.AddGroupCommandTests {
    @Test
    func addGroup_shouldAddGroup_whenGroupExistsOnDisk() throws {
        let group = Files.Helpers.GeneralUtils.NotAdded.group.asInputPath
        var sut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try expectGroupInProject(group)
        try validateProject()
    }

    @Test
    func addGroup_shouldReturnError_whenGroupDoesNotExistOnDisk() throws {
        let group = "Helpers/NonExistentGroup".asInputPath
        let sut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath
        ])

        #expect(throws: XcodeProjectError.groupNotFoundOnDisk(group)) {
            try sut.run()
        }
    }

    @Test
    func addGroup_shouldCreateHierarchy_whenCreateGroupsSet() throws {
        let group = "Helpers/NonExistent1/NonExistentGroup".asInputPath
        var sut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath,
            "--create-groups"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try expectGroupInProject(group.parent!)
        try expectGroupInProject(group)
        try validateProject()
    }

    @Test
    func addGroup_shouldAddNestedGroupHierarchy_whenParentGroupsDoNotExist() throws {
        let group = Files.Helpers.GeneralUtils.NotAdded.NotAdded.group.asInputPath
        var sut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        try expectGroupInProject(group.parent!)
        try expectGroupInProject(group)
        try validateProject()
    }

    @Test
    func addGroup_shouldPrintWarning_whenGroupAlreadyExistsInProject() throws {
        let group = Files.Helpers.GeneralUtils.group
        var sut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            group
        ])

        let output = try runTest(for: &sut)
        #expect(output.contains("Warning: Group already exists"))
        try validateProject()
    }
}
