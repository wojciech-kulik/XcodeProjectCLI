import Foundation
import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("Delete Asset Command", .serialized)
    final class DeleteAssetCommandTests: ProjectAssetsTests {}
}

extension SerializedSuite.DeleteAssetCommandTests {
    @Test
    func deleteAsset_shouldDeleteAsset() throws {
        let assetPath = "Folder/SomeImage"
        let command = try DeleteAssetCommand.parse([
            testXCAssetsPath,
            "--asset-path",
            assetPath
        ])

        try command.run()

        #expect(!FileManager.default.fileExists(
            atPath: "\(testXCAssetsPath)/Folder/SomeImage.imageset"
        ))
    }

    @Test
    func deleteAsset_shouldReturnError_whenFileDoesNotExistOnDisk() throws {
        let file = "NonExistingFile.png"

        let sut = try DeleteAssetCommand.parse([
            testXCAssetsPath,
            "--asset-path",
            file
        ])

        #expect(throws: XcodeProjectError.assetNotFound(file)) {
            try sut.run()
        }
    }
}
