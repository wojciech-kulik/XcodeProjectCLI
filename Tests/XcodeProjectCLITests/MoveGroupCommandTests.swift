import Foundation
import Testing
@testable import XcodeProject
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Move Group Command", .serialized)
    final class MoveGroupCommandTests: ProjectTests {}
}

// MARK: Basic Functionality
// ---------------------------------------------------------------------------------------
extension SerializedSuite.MoveGroupCommandTests {
    @Test
    func moveGroup_shouldMoveGroupInProjectAndOnDisk_andShouldNotChangeTarget() throws {
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
        try expectTargets(
            ["Helpers", "XcodebuildNvimApp"],
            forFile: newGroupPath.asInputPath.appending("String+Extensions.swift")
        )
        try validateProject()
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

        #expect(throws: XcodeProjectError.groupNotFoundOnDisk(group)) {
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

        #expect(throws: XcodeProjectError.groupNotFoundInProject(group)) {
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
        try validateProject()
    }
}

// MARK: Merging Groups
// ---------------------------------------------------------------------------------------
extension SerializedSuite.MoveGroupCommandTests {
    @Test
    func moveGroup_shouldMergeGroups_whenGroupWithSameNameExistsInDestination() throws {
        // Setup: Create a group "Subfolder1" in Modules with a file
        let destGroup = Files.XcodebuildNvimApp.Modules.group
        let destSubfolder = "\(destGroup)/Subfolder1"
        let fileInDest = "\(destSubfolder)/ExistingFile.swift"

        // Create the destination subfolder on disk
        try FileManager.default.createDirectory(
            atPath: destSubfolder.asInputPath.absolutePath,
            withIntermediateDirectories: true
        )

        // Create the destination subfolder in project
        var addDestSut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            destSubfolder
        ])
        _ = try runTest(for: &addDestSut)

        // Add a file to destination Subfolder1
        try "// Existing file".write(toFile: fileInDest.asInputPath.absolutePath, atomically: true, encoding: .utf8)
        var addFileSut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            fileInDest,
            "--targets",
            "XcodebuildNvimApp"
        ])
        _ = try runTest(for: &addFileSut)

        // Move Helpers/GeneralUtils/Subfolder1 (which has CustomFile.swift) to Modules
        let sourceGroup = Files.Helpers.GeneralUtils.Subfolder1.group
        var sut = try MoveGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            sourceGroup,
            "--dest",
            destGroup
        ])

        let output = try runTest(for: &sut)
        #expect(output == "Warning: Merging group 'Subfolder1' into existing group at destination.")

        // Source should not exist anymore
        try notExpectGroupInProject(sourceGroup.asInputPath)

        // Destination Subfolder1 should exist and contain both files
        try expectGroupInProject(destSubfolder.asInputPath)
        try expectFileInProject(fileInDest.asInputPath)
        try expectFileInProject("\(destSubfolder)/CustomFile.swift".asInputPath)

        try validateProject()
    }

    @Test
    func moveGroup_shouldMergeNestedGroupsRecursively_whenPartialHierarchyExists() throws {
        // Setup: Create a partial hierarchy in destination
        // XcodebuildNvimApp/Modules/GeneralUtils (new location)
        // XcodebuildNvimApp/Modules/GeneralUtils/Subfolder2 (already exists with a file)
        let destGroup = Files.XcodebuildNvimApp.Modules.group
        let destGeneralUtils = "\(destGroup)/GeneralUtils"
        let destSubfolder2 = "\(destGeneralUtils)/Subfolder2"
        let fileInDest = "\(destSubfolder2)/DestFile.swift"

        // Create destination hierarchy on disk
        try FileManager.default.createDirectory(
            atPath: destSubfolder2.asInputPath.absolutePath,
            withIntermediateDirectories: true
        )

        // Create destination hierarchy in project
        var addDestSut = try AddGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            destSubfolder2
        ])
        _ = try runTest(for: &addDestSut)

        // Add a file to destination Subfolder2
        try "// Destination file".write(toFile: fileInDest.asInputPath.absolutePath, atomically: true, encoding: .utf8)
        var addFileSut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            fileInDest,
            "--targets",
            "XcodebuildNvimApp"
        ])
        _ = try runTest(for: &addFileSut)

        // Move Helpers/GeneralUtils (has Subfolder1, Subfolder2, RandomFile.swift) to Modules
        let sourceGroup = Files.Helpers.GeneralUtils.group
        var sut = try MoveGroupCommand.parse([
            testXcodeprojPath,
            "--group",
            sourceGroup,
            "--dest",
            destGroup
        ])

        let output = try runTest(for: &sut)
        #expect(output == "Warning: Merging group 'GeneralUtils' into existing group at destination.")

        // Source should not exist anymore
        try notExpectGroupInProject(sourceGroup.asInputPath)

        // Destination should have merged structure
        try expectGroupInProject(destGeneralUtils.asInputPath)
        try expectGroupInProject("\(destGeneralUtils)/Subfolder1".asInputPath)
        try expectGroupInProject(destSubfolder2.asInputPath)

        // Files from both source and destination should exist
        try expectFileInProject(fileInDest.asInputPath) // Original file in destination
        try expectFileInProject("\(destSubfolder2)/String+Extensions.swift".asInputPath) // Moved file
        try expectFileInProject("\(destGeneralUtils)/Subfolder1/CustomFile.swift".asInputPath) // Moved from source
        try expectFileInProject("\(destGeneralUtils)/RandomFile.swift".asInputPath) // Moved from source

        try validateProject()
    }
}
