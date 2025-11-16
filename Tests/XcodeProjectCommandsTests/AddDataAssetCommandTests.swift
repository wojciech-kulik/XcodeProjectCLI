
import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("Add Data Asset Command", .serialized)
    final class AddDataAssetCommandTests: ProjectAssetsTests {}
}

extension SerializedSuite.AddDataAssetCommandTests {
    @Test
    func addImageAsset_shouldAddDataAsset() throws {
        let assetPath = "Raw/DataFile.txt"
        let command = try AddDataAssetCommand.parse([
            testXCAssetsPath,
            "--file",
            dataFilePath,
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Raw/DataFile.dataset/Contents.json",
            and: "\(testResourcesPath)/DataFile.json"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Raw/DataFile.dataset/DataFile.txt",
            and: "\(testResourcesPath)/DataFile.txt"
        )
    }
}
