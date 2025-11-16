import Foundation

public final class ProjectAssets {
    private let xcassetsPath: InputPath

    public init(xcassetsPath: String) {
        self.xcassetsPath = xcassetsPath.asAbsoluteInputPath
    }

    public func listAll() throws -> [AssetType: [String]] {
        var assets: [AssetType: [String]] = [:]

        let fileEnumerator = FileManager.default.enumerator(
            atPath: xcassetsPath.absolutePath
        )

        let allowedExtensions = AssetType.allCases.map(\.ext)

        while let element = fileEnumerator?.nextObject() as? String {
            let url = URL(fileURLWithPath: element)
            let ext = url.pathExtension

            if allowedExtensions.contains(ext) {
                let assetType = AssetType.allCases.first { $0.ext == ext }!
                let assetPath = url.deletingPathExtension().path
                assets[assetType, default: []].append(assetPath)
            }
        }

        return assets
    }

    public func addImage(
        filePath: InputPath,
        darkFilePath: InputPath? = nil,
        assetPath: String,
        renderingMode: RenderingMode = .default
    ) throws {
        let asset = AssetInfo(
            xcassetsPath: xcassetsPath,
            assetPath: assetPath,
            type: .image
        )

        try FileManager.default.createDirectory(
            atPath: asset.directory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        try FileManager.default.copyItem(
            atPath: filePath.absolutePath,
            toPath: asset.filePath
        )

        if let darkFilePath {
            try FileManager.default.copyItem(
                atPath: darkFilePath.absolutePath,
                toPath: asset.darkFilePath
            )
        }

        let template = ImageAssetBuilder(asset)
            .setRenderingMode(renderingMode)
            .includeDarkAppearance()
            .build()

        try template.write(
            toFile: asset.contentsPath,
            atomically: true,
            encoding: .utf8
        )
    }

    public func addData(filePath: InputPath, assetPath: String) throws {
        let asset = AssetInfo(
            xcassetsPath: xcassetsPath,
            assetPath: assetPath,
            type: .data
        )

        try FileManager.default.createDirectory(
            atPath: asset.directory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        try FileManager.default.copyItem(
            atPath: filePath.absolutePath,
            toPath: asset.filePath
        )

        let template = DataAssetBuilder(asset)
            .build()

        try template.write(
            toFile: asset.contentsPath,
            atomically: true,
            encoding: .utf8
        )
    }

    public func addColor(
        hexColor: String,
        darkHexColor: String?,
        colorSpace: String = "srgb",
        assetPath: String
    ) throws {
        let asset = AssetInfo(
            xcassetsPath: xcassetsPath,
            assetPath: assetPath,
            type: .color
        )

        try FileManager.default.createDirectory(
            atPath: asset.directory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let template = ColorAssetBuilder()
            .setHexColor(hexColor)
            .setDarkHexColor(darkHexColor)
            .setColorSpace(colorSpace)
            .build()

        try template.write(
            toFile: asset.contentsPath,
            atomically: true,
            encoding: .utf8
        )
    }

    public func moveAsset(
        oldAssetPath: String,
        newAssetPath: String
    ) throws {
        let type = try findAssetType(from: oldAssetPath)

        let oldAsset = AssetInfo(
            xcassetsPath: xcassetsPath,
            assetPath: oldAssetPath,
            type: type
        )

        let newAsset = AssetInfo(
            xcassetsPath: xcassetsPath,
            assetPath: newAssetPath,
            type: type
        )

        try FileManager.default.moveItem(
            atPath: oldAsset.directory,
            toPath: newAsset.directory
        )
    }

    public func deleteAsset(assetPath: String) throws {
        let asset = try AssetInfo(
            xcassetsPath: xcassetsPath,
            assetPath: assetPath,
            type: findAssetType(from: assetPath)
        )

        try FileManager.default.removeItem(atPath: asset.directory)
    }

    private func findAssetType(from assetPath: String) throws -> AssetType {
        let assetType = AssetType.allCases.first { type in
            let fullPath = xcassetsPath.appending("\(assetPath).\(type.ext)").absolutePath
            return FileManager.default.fileExists(atPath: fullPath)
        }

        guard let assetType else {
            throw XcodeProjectError.assetNotFound(assetPath)
        }

        return assetType
    }
}
