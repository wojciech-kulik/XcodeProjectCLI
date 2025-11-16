import ArgumentParser
import XcodeProject

public struct MoveAssetCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "move-asset",
        abstract: "Move an asset."
    )

    @Argument
    var xcassetsPath: String

    @Option(help: "Asset path relative to xcassets. E.g. 'Folder/File'")
    var assetPath: String

    @Option(help: "Destination path relative to xcassets. E.g. 'NewFolder/NewFile'")
    var dest: String

    public init() {}

    public func run() throws {
        let projectAssets = ProjectAssets(xcassetsPath: xcassetsPath)
        try projectAssets.moveAsset(
            oldAssetPath: assetPath,
            newAssetPath: dest
        )
    }
}
