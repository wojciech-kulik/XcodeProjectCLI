import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("Add Image Asset Command", .serialized)
    final class AddImageAssetCommandTests: ProjectAssetsTests {}
}

extension SerializedSuite.AddImageAssetCommandTests {
    @Test
    func addImageAsset_shouldAddImageAsset_light() throws {
        let assetPath = "Icons/Image.png"
        let command = try AddImageAssetCommand.parse([
            testXCAssetsPath,
            "--file",
            lightImagePath,
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Contents.json",
            and: "\(testResourcesPath)/ImageUniversal.json"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Image.png",
            and: "\(testResourcesPath)/Image.png"
        )
    }

    @Test
    func addImageAsset_shouldAddImageAsset_toExistingFolder() throws {
        let assetPath = "Folder/Image.png"
        let command = try AddImageAssetCommand.parse([
            testXCAssetsPath,
            "--file",
            lightImagePath,
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Folder/Image.imageset/Contents.json",
            and: "\(testResourcesPath)/ImageUniversal.json"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Folder/Image.imageset/Image.png",
            and: "\(testResourcesPath)/Image.png"
        )
    }

    @Test
    func addImageAsset_shouldAddImageAsset_toRoot() throws {
        let assetPath = "Image.png"
        let command = try AddImageAssetCommand.parse([
            testXCAssetsPath,
            "--file",
            lightImagePath,
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Image.imageset/Contents.json",
            and: "\(testResourcesPath)/ImageUniversal.json"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Image.imageset/Image.png",
            and: "\(testResourcesPath)/Image.png"
        )
    }

    @Test
    func addImageAsset_shouldAddImageAsset_dark() throws {
        let assetPath = "Icons/Image.png"
        let command = try AddImageAssetCommand.parse([
            testXCAssetsPath,
            "--file",
            lightImagePath,
            "--dark-file",
            darkImagePath,
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Contents.json",
            and: "\(testResourcesPath)/ImageWithDark.json"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Image.png",
            and: "\(testResourcesPath)/Image.png"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Image_dark.png",
            and: "\(testResourcesPath)/ImageDark.png"
        )
    }

    @Test
    func addImageAsset_shouldAddImageAsset_darkAndTemplated() throws {
        let assetPath = "Icons/Image.png"
        let command = try AddImageAssetCommand.parse([
            testXCAssetsPath,
            "--file",
            lightImagePath,
            "--dark-file",
            darkImagePath,
            "--asset-path",
            assetPath,
            "--mode",
            "template"
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Contents.json",
            and: "\(testResourcesPath)/ImageWithDarkTemplated.json"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Image.png",
            and: "\(testResourcesPath)/Image.png"
        )
        try expectSameFiles(
            at: "\(testXCAssetsPath)/Icons/Image.imageset/Image_dark.png",
            and: "\(testResourcesPath)/ImageDark.png"
        )
    }

    @Test
    func addImageAsset_shouldThrowException_whenFileDoesntExist() throws {
        let assetPath = "Icons/Image.png"
        let nonExistentDataFilePath = "\(testResourcesPath)/NonExistentFile.jpg"
        let command = try AddImageAssetCommand.parse([
            testXCAssetsPath,
            "--file",
            nonExistentDataFilePath,
            "--asset-path",
            assetPath
        ])

        #expect(throws: XcodeProjectError.fileNotFoundOnDisk(
            nonExistentDataFilePath.asAbsoluteInputPath
        )) {
            try command.run()
        }
    }
}
