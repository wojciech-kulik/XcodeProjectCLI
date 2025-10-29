extension String {
    var trimTrailingSlash: String {
        guard hasSuffix("/"), self != "/" else { return self }
        return String(dropLast())
    }
}
