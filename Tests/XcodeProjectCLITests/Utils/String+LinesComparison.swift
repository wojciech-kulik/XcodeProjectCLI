extension String {
    static func == (lhs: String, rhs: [String]) -> Bool {
        lhs == rhs.joined(separator: "\n")
    }
}
