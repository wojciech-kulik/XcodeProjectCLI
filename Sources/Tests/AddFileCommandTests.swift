import Testing
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Add File Command", .serialized)
    final class AddFileCommandTests: ProjectTests {}
}

// MARK: Basic Functionality
// ---------------------------------------------------------------------------------------
extension SerializedSuite.AddFileCommandTests {
    @Test
    func addFile_shouldAddFile_whenGroupAlreadyExists() throws {
        let file = Files.XcodebuildNvimApp.Modules.notAddedFile
        var sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--targets",
            "Helpers,EmptyTarget"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: file)
        #expect(targets == ["EmptyTarget", "Helpers"])
    }

    @Test
    func addFile_shouldReturnError_whenFileDoesNotExist() throws {
        let sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            "Helpers/NonExistentFile.swift",
            "--targets",
            "Helpers,EmptyTarget"
        ])

        do {
            try sut.run()
        } catch let error as CLIError {
            #expect(error.description ==
                "File \(testProjectPath)/Helpers/NonExistentFile.swift does not exist.")
        }
    }

    @Test
    func addFile_shouldReturnError_whenTargetDoesNotExist() throws {
        let sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            Files.XcodebuildNvimApp.Modules.notAddedFile,
            "--targets",
            "Helpers,NonExistentTarget"
        ])

        do {
            try sut.run()
        } catch let error as CLIError {
            #expect(error.description == "One or more specified targets do not exist in the project.")
        }
    }
}

// MARK: Group Hierarchy Creation
// ---------------------------------------------------------------------------------------
extension SerializedSuite.AddFileCommandTests {
    @Test
    func addFile_shouldAddFileAndCreateGroup_whenGroupDoesNotExist() throws {
        let file = Files.XcodebuildNvimApp.Modules.NotAdded.notAddedFile
        var sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--targets",
            "Helpers,EmptyTarget",
            "--create-groups"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: file)
        #expect(targets == ["EmptyTarget", "Helpers"])
    }

    @Test
    func addFile_shouldAddFileAndCreateMultipleGroups_whenGroupHierarchyDoesNotExist() throws {
        let file = Files.Helpers.GeneralUtils.NotAdded.NotAdded.notAddedFile
        var sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--targets",
            "Helpers,EmptyTarget",
            "--create-groups"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: file)
        #expect(targets == ["EmptyTarget", "Helpers"])
    }

    @Test
    func addFile_shouldReturnError_whenGroupDoesNotExistAndCreateGroupsNotSet() throws {
        let file = Files.XcodebuildNvimApp.Modules.NotAdded.notAddedFile
        let sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--targets",
            "Helpers,EmptyTarget"
        ])

        do {
            try sut.run()
        } catch let error as CLIError {
            #expect(error.description ==
                "Group at path \(file.asInputPath.directory) not found. Use --create-groups to create missing groups.")
        }
    }
}

// MARK: Automatic Target Detection
// ---------------------------------------------------------------------------------------
extension SerializedSuite.AddFileCommandTests {
    @Test
    func addFile_shouldAddFileAndGuessTarget_whenOtherSwiftFileIsOnTheSameTreeLevel() throws {
        let file = Files.XcodebuildNvimApp.Modules.notAddedFile
        var sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--guess-target"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: file)
        #expect(targets == ["XcodebuildNvimApp"])
    }

    @Test
    func addFile_shouldAddFileAndGuessTarget_whenNoOtherSwiftFileInTree() throws {
        let file = Files.Helpers.notAddedFile
        var sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--guess-target"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: file)
        #expect(targets == ["Helpers"])
    }

    @Test
    func addFile_shouldAddFileAndGuessTarget_whenNextSwiftFileIsInParentDir() throws {
        let file = Files.Helpers.GeneralUtils.NotAdded.notAddedFile
        var sut = try AddFileCommand.parse([
            testXcodeprojPath,
            "--file",
            file,
            "--guess-target",
            "--create-groups"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = try targets(forFile: file)
        #expect(targets == ["Helpers", "XcodebuildNvimApp", "XcodebuildNvimAppTests"])
    }
}
