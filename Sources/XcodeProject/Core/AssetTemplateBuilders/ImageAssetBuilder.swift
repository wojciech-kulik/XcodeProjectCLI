final class ImageAssetBuilder {
    private var renderingMode: RenderingMode = .default
    private var includeDark = false

    private let asset: AssetInfo

    init(_ asset: AssetInfo) {
        self.asset = asset
    }

    func setRenderingMode(_ mode: RenderingMode) -> ImageAssetBuilder {
        renderingMode = mode
        return self
    }

    func includeDarkAppearance(_ includeDark: Bool) -> ImageAssetBuilder {
        self.includeDark = includeDark
        return self
    }

    func build() -> String {
        let templateRendering = renderingMode != .default
            ? """
            ,
              "properties" : {
                "template-rendering-intent" : "\(renderingMode.rawValue)"
              }
            """
            : ""

        let darkAppearance = includeDark
            ? """
            ,
                {
                  "appearances" : [
                    {
                      "appearance" : "luminosity",
                      "value" : "dark"
                    }
                  ],
                  "filename" : "\(asset.darkFileName)",
                  "idiom" : "universal"
                }
            """
            : ""

        return """
        {
          "images" : [
            {
              "filename" : "\(asset.fileName)",
              "idiom" : "universal"
            }\(darkAppearance)
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }\(templateRendering)
        }\n
        """
    }
}
