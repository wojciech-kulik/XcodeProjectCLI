import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("List Targets Command", .serialized)
    final class ListTargetsCommandTests: ProjectTests {}
}

// MARK: List All Targets
// ---------------------------------------------------------------------------------------
extension SerializedSuite.ListTargetsCommandTests {
    @Test
    func listTargets_shouldReturnTargets() throws {
        var sut = try ListTargetsCommand.parse([testXcodeprojPath])

        let output = try runTest(for: &sut)

        #expect(output == [
            "EmptyTarget",
            "Helpers",
            "XcodebuildNvimApp",
            "XcodebuildNvimAppTests",
            "XcodebuildNvimAppUITests"
        ])
    }
}

// MARK: List Targets by File Path
// ---------------------------------------------------------------------------------------
extension SerializedSuite.ListTargetsCommandTests {
    @Test(arguments: 0...1)
    func listTargets_byFilePath_shouldReturnTargets(testCase: Int) throws {
        let testCases = [
            (input: Files.Helpers.GeneralUtils.Subfolder2.stringExtensions, expected: [
                "Helpers",
                "XcodebuildNvimApp"
            ]),
            (input: Files.Helpers.GeneralUtils.randomFile, expected: [
                "Helpers",
                "XcodebuildNvimApp",
                "XcodebuildNvimAppTests"
            ])
        ]
        var sut = try ListTargetsCommand.parse([
            testXcodeprojPath,
            "--file",
            testCases[testCase].input
        ])

        let output = try runTest(for: &sut)

        #expect(output == testCases[testCase].expected)
    }

    func listTargets_byResourceFilePath_shouldReturnTarget() throws {
        var sut = try ListTargetsCommand.parse([
            testXcodeprojPath,
            "--file",
            Files.XcodebuildNvimApp.Modules.image
        ])

        let output = try runTest(for: &sut)

        #expect(output == [
            "Helpers",
            "XcodebuildNvimApp"
        ])
    }

    @Test
    func listTargets_byFilePath_shouldReturnError_whenFileIsNotAddedToAnyTarget() throws {
        let file = Files.Helpers.notAddedFile.asInputPath
        let sut = try ListTargetsCommand.parse([
            testXcodeprojPath,
            "--file",
            file.relativePath
        ])

        #expect(throws: XcodeProjectError.fileNotFoundInProject(file)) {
            try sut.run()
        }
    }
}

// MARK: List Targets by Group Path
// ---------------------------------------------------------------------------------------
extension SerializedSuite.ListTargetsCommandTests {
    @Test(arguments: 0...1)
    func listTargets_byGroupPath_shouldReturnTargetsForFirstSwiftFile(testCase: Int) throws {
        let testCases = [
            (input: Files.Helpers.GeneralUtils.Subfolder2.group, expected: [
                "Helpers",
                "XcodebuildNvimApp"
            ]),
            (input: Files.Helpers.GeneralUtils.group, expected: [
                "Helpers",
                "XcodebuildNvimApp",
                "XcodebuildNvimAppTests"
            ])
        ]
        var sut = try ListTargetsCommand.parse([testXcodeprojPath, "--group", testCases[testCase].input])

        let output = try runTest(for: &sut)

        #expect(output == testCases[testCase].expected)
    }

    @Test
    func listTargets_byGroupPath_shouldReturnError_whenGroupIsNotAddedToAnyTarget() throws {
        let group = Files.XcodebuildNvimApp.Modules.NotAdded.group.asInputPath
        let sut = try ListTargetsCommand.parse([
            testXcodeprojPath,
            "--group",
            group.relativePath
        ])

        #expect(throws: XcodeProjectError.groupNotFoundInProject(group)) {
            try sut.run()
        }
    }
}
