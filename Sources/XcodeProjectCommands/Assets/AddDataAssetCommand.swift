import ArgumentParser
import XcodeProject

public struct AddDataAssetCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "add-data-asset",
        abstract: "Add data asset."
    )

    @Argument
    var xcassetsPath: String

    @Option(name: .customLong("file"), help: "File path.")
    var filePath: String

    @Option(help: "Asset path relative to xcassets. E.g. 'Folder/File.txt'")
    var assetPath: String

    public init() {}

    public func run() throws {
        let projectAssets = ProjectAssets(xcassetsPath: xcassetsPath)
        try projectAssets.addData(
            filePath: filePath.asAbsoluteInputPath,
            assetPath: assetPath
        )
    }
}
