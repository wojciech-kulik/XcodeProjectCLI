import ArgumentParser
import XcodeProject

public struct DeleteAssetCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "delete-asset",
        abstract: "Delete asset."
    )

    @Argument
    var xcassetsPath: String

    @Option(help: "Asset path relative to xcassets. E.g. 'Folder/File'")
    var assetPath: String

    public init() {}

    public func run() throws {
        let projectAssets = ProjectAssets(xcassetsPath: xcassetsPath)
        try projectAssets.deleteAsset(
            assetPath: assetPath
        )
    }
}
