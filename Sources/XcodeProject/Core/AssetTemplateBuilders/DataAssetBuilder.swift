final class DataAssetBuilder {
    private let asset: AssetInfo

    init(_ asset: AssetInfo) {
        self.asset = asset
    }

    func build() -> String {
        let template = """
        {
          "data" : [
            {
              "filename" : "\(asset.fileName)",
              "idiom" : "universal"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
        return template
    }
}
