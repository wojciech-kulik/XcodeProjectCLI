struct HexColor {
    let red: String
    let green: String
    let blue: String
    let alpha: String

    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }

        if hexString.count == 8 {
            let alphaHex = String(hexString.prefix(2))
            let alphaValue = Double(Int(alphaHex, radix: 16) ?? 255) / 255.0
            let formattedAlpha = String(format: "%.2f", alphaValue)
            self.alpha = formattedAlpha
            hexString = String(hexString.dropFirst(2))
        } else {
            self.alpha = "1.0"
        }

        self.red = String(hexString.prefix(2))
        self.green = String(hexString.dropFirst(2).prefix(2))
        self.blue = String(hexString.dropFirst(4).prefix(2))
    }
}
