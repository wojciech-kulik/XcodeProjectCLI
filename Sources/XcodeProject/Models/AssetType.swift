public enum AssetType: CaseIterable {
    case image
    case data
    case color

    public var ext: String {
        switch self {
        case .image: return "imageset"
        case .data: return "dataset"
        case .color: return "colorset"
        }
    }
}
