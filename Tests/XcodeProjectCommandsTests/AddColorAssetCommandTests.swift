import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("Add Color Asset Command", .serialized)
    final class AddColorAssetCommandTests: ProjectAssetsTests {}
}

extension SerializedSuite.AddColorAssetCommandTests {
    @Test
    func addColorAsset_shouldAddUniversalColorAsset() throws {
        let assetPath = "Colors/Red"
        let command = try AddColorAssetCommand.parse([
            testXCAssetsPath,
            "--color",
            "#FF0000",
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Colors/Red.colorset/Contents.json",
            and: "\(testResourcesPath)/Red.json"
        )
    }

    @Test
    func addColorAsset_shouldAddLightAndDarkColorAsset() throws {
        let assetPath = "Colors/RedAndGreen"
        let command = try AddColorAssetCommand.parse([
            testXCAssetsPath,
            "--color",
            "#FF0000",
            "--dark-color",
            "#00FF00",
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Colors/RedAndGreen.colorset/Contents.json",
            and: "\(testResourcesPath)/RedAndGreen.json"
        )
    }

    @Test
    func addColorAsset_shouldAddLightAndDarkColorAsset_withAlpha() throws {
        let assetPath = "Colors/RedAndGreenAlpha"
        let command = try AddColorAssetCommand.parse([
            testXCAssetsPath,
            "--color",
            "#7FFF0000",
            "--dark-color",
            "#6600FF00",
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Colors/RedAndGreenAlpha.colorset/Contents.json",
            and: "\(testResourcesPath)/RedAndGreenAlpha.json"
        )
    }

    @Test
    func addColorAsset_shouldAddLightAndDarkColorAsset_withDisplayP3Space() throws {
        let assetPath = "Colors/RedAndGreenAlphaDisplayP3"
        let command = try AddColorAssetCommand.parse([
            testXCAssetsPath,
            "--color",
            "#7FFF0000",
            "--dark-color",
            "#6600FF00",
            "--color-space",
            "display-p3",
            "--asset-path",
            assetPath
        ])

        try command.run()

        try expectSameFiles(
            at: "\(testXCAssetsPath)/Colors/RedAndGreenAlphaDisplayP3.colorset/Contents.json",
            and: "\(testResourcesPath)/RedAndGreenAlphaDisplayP3.json"
        )
    }
}
