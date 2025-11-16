import Foundation
import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("Move Asset Command", .serialized)
    final class MoveAssetCommandTests: ProjectAssetsTests {}
}

extension SerializedSuite.MoveAssetCommandTests {
    @Test
    func moveAsset_shouldMoveAsset() throws {
        let assetPath = "Folder/SomeImage"
        let command = try MoveAssetCommand.parse([
            testXCAssetsPath,
            "--asset-path",
            assetPath,
            "--dest",
            "NewFolder/MovedImage"
        ])

        try command.run()

        #expect(!FileManager.default.fileExists(
            atPath: "\(testXCAssetsPath)/Folder/SomeImage.imageset"
        ))
        #expect(FileManager.default.fileExists(
            atPath: "\(testXCAssetsPath)/NewFolder/MovedImage.imageset"
        ))
    }

    @Test
    func moveAsset_shouldReturnError_whenFileDoesNotExistOnDisk() throws {
        let file = "Folder/NonExistingFile.png"

        let sut = try MoveAssetCommand.parse([
            testXCAssetsPath,
            "--asset-path",
            file,
            "--dest",
            "SomeDestination/Image.png"
        ])

        #expect(throws: XcodeProjectError.assetNotFound(file)) {
            try sut.run()
        }
    }
}
