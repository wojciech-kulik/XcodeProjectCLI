extension Collection {
    var isNotEmpty: Bool { !isEmpty }

    func notContains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try !contains(where: predicate)
    }

    func notContains(_ element: Element) -> Bool where Element: Equatable {
        !contains(element)
    }
}
