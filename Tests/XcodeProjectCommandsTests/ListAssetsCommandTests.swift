import Foundation
import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("List Assets Command", .serialized)
    final class ListAssetsCommandTests: ProjectAssetsTests {}
}

extension SerializedSuite.ListAssetsCommandTests {
    @Test
    func listAssets_shouldReturnAllAssets() throws {
        var command = try ListAssetsCommand.parse([
            testXCAssetsPath
        ])

        let output = try runTest(for: &command)

        #expect(output == """
        > Images
        Folder/SomeImage
        Folder2/NestedFolder/NewImage

        > Data Files
        Folder2/NestedFolder/SampleData

        > Colors
        AccentColor
        """)
    }

    @Test
    func listAssets_shouldReturnColors() throws {
        var command = try ListAssetsCommand.parse([
            testXCAssetsPath,
            "--type",
            "color"
        ])

        let output = try runTest(for: &command)

        #expect(output == """
        AccentColor
        """)
    }

    @Test
    func listAssets_shouldReturnDataFiles() throws {
        var command = try ListAssetsCommand.parse([
            testXCAssetsPath,
            "--type",
            "data"
        ])

        let output = try runTest(for: &command)

        #expect(output == """
        Folder2/NestedFolder/SampleData
        """)
    }

    @Test
    func listAssets_shouldReturnImageFiles() throws {
        var command = try ListAssetsCommand.parse([
            testXCAssetsPath,
            "--type",
            "image"
        ])

        let output = try runTest(for: &command)

        #expect(output == """
        Folder/SomeImage
        Folder2/NestedFolder/NewImage
        """)
    }
}
