import ArgumentParser
import XcodeProject

public struct AddColorAssetCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "add-color-asset",
        abstract: "Add a color asset to a given xcassets."
    )

    @Argument
    var xcassetsPath: String

    @Option(help: "Hex color in format #RRGGBB or #RRGGBBAA.")
    var color: String

    @Option(help: "Hex color for Dark Appearance in format #RRGGBB or #RRGGBBAA.")
    var darkColor: String?

    @Option(help: "Color space (default: srgb).")
    var colorSpace: String = "srgb"

    @Option(help: "Asset path relative to xcassets. E.g. 'Folder/ColorName'")
    var assetPath: String

    public init() {}

    public func run() throws {
        let projectAssets = ProjectAssets(xcassetsPath: xcassetsPath)
        try projectAssets.addColor(
            hexColor: color,
            darkHexColor: darkColor,
            colorSpace: colorSpace,
            assetPath: assetPath
        )
    }
}
