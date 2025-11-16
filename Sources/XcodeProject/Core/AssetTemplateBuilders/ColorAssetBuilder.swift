final class ColorAssetBuilder {
    private var hexColor: String?
    private var darkHexColor: String?
    private var colorSpace = "srgb"

    func setHexColor(_ hex: String) -> ColorAssetBuilder {
        hexColor = hex
        return self
    }

    func setDarkHexColor(_ hex: String?) -> ColorAssetBuilder {
        darkHexColor = hex
        return self
    }

    func setColorSpace(_ space: String) -> ColorAssetBuilder {
        colorSpace = space
        return self
    }

    func build() -> String {
        var darkColorTemplate = ""

        if let darkColor = darkHexColor.flatMap(HexColor.init) {
            darkColorTemplate = """
            ,
                {
                  "appearances" : [
                    {
                      "appearance" : "luminosity",
                      "value" : "dark"
                    }
                  ],
                  "color" : {
                    "color-space" : "\(colorSpace)",
                    "components" : {
                      "alpha" : "\(darkColor.alpha)",
                      "blue" : "0x\(darkColor.blue)",
                      "green" : "0x\(darkColor.green)",
                      "red" : "0x\(darkColor.red)"
                    }
                  },
                  "idiom" : "universal"
                }
            """
        }

        guard let color = hexColor.flatMap(HexColor.init) else {
            return ""
        }

        return """
        {
          "colors" : [
            {
              "color" : {
                "color-space" : "\(colorSpace)",
                "components" : {
                  "alpha" : "\(color.alpha)",
                  "blue" : "0x\(color.blue)",
                  "green" : "0x\(color.green)",
                  "red" : "0x\(color.red)"
                }
              },
              "idiom" : "universal"
            }\(darkColorTemplate)
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }\n
        """
    }
}
