final class DataAssetBuilder {
    private let asset: AssetInfo

    init(_ asset: AssetInfo) {
        self.asset = asset
    }

    func build() -> String {
        """
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
        }\n
        """
    }
}
