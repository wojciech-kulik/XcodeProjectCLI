import ArgumentParser
import XcodeProject

public struct ListAssetsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list-assets",
        abstract: "List all assets."
    )

    @Argument
    var xcassetsPath: String

    @Option(help: .init("Filter by asset type (default: all).", valueName: "color|data|image"))
    var type: String?

    public init() {}

    public func run() throws {
        let projectAssets = ProjectAssets(xcassetsPath: xcassetsPath)

        let assetType: AssetType? = {
            guard let type else { return nil }
            switch type.lowercased() {
            case "color": return .color
            case "data": return .data
            case "image": return .image
            default: return nil
            }
        }()

        let assets = try projectAssets.listAll()

        let filteredAssets = assets.filter { asset in
            guard let assetType else { return true }
            return asset.key == assetType
        }

        let allTypes = filteredAssets.keys
            .sorted(by: { $0.rawValue < $1.rawValue })

        for (index, assetType) in allTypes.enumerated() {
            if index > 0 {
                print("")
            }

            if type == nil {
                print("> \(assetType.title)")
            }

            let fileteredPaths = filteredAssets[assetType] ?? []
            for path in fileteredPaths.sorted() {
                print(path)
            }
        }
    }
}

extension AssetType {
    var title: String {
        switch self {
        case .image: return "Images"
        case .data: return "Data Files"
        case .color: return "Colors"
        }
    }
}
