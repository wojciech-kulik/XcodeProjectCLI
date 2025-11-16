import ArgumentParser
import XcodeProject

extension RenderingMode: ExpressibleByArgument {}

public struct AddImageAssetCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "add-image-asset",
        abstract: "Add an image asset."
    )

    @Argument
    var xcassetsPath: String

    @Option(name: .customLong("file"), help: .init(
        "File path.",
        discussion: "Image will be added to Any Appearance.",
        valueName: "file-path"
    ))
    var filePath: String

    @Option(name: .customLong("dark-file"), help: .init(
        "File path.",
        discussion: "Image will be added to Dark Appearance.",
        valueName: "file-path"
    ))
    var darkFilePath: String?

    @Option(help: "Asset path relative to xcassets. E.g. 'Folder/Image.png'")
    var assetPath: String

    @Option(name: .customLong("mode"), help: .init("Rendering mode.", valueName: "default|template|original"))
    var renderingMode: RenderingMode = .default

    public init() {}

    public func run() throws {
        let projectAssets = ProjectAssets(xcassetsPath: xcassetsPath)
        try projectAssets.addImage(
            filePath: filePath.asAbsoluteInputPath,
            darkFilePath: darkFilePath?.asAbsoluteInputPath,
            assetPath: assetPath,
            renderingMode: renderingMode
        )
    }
}
