import Foundation

struct InputPath: Equatable, Hashable {
    let path: String
    let projectRoot: String

    init(_ path: String, projectRoot: String?) {
        self.path = path.trimTrailingSlash

        if let projectRoot {
            self.projectRoot = projectRoot.trimTrailingSlash
        } else {
            self.projectRoot = ""
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(absolutePath)
    }

    static func == (lhs: InputPath, rhs: InputPath) -> Bool {
        lhs.absolutePath == rhs.absolutePath
    }
}

// MARK: - Path Manipulation
extension InputPath {
    var directory: InputPath {
        InputPath(
            nsString.deletingLastPathComponent,
            projectRoot: projectRoot
        )
    }

    /// Returns nil if the root has been reached.
    var parent: InputPath? {
        let parentPath = (relativePath as NSString).deletingLastPathComponent

        guard parentPath != path else { return nil }

        return InputPath(parentPath, projectRoot: projectRoot)
    }

    func appending(_ component: String) -> InputPath {
        let newPath = nsString.appendingPathComponent(component)
        return InputPath(newPath, projectRoot: projectRoot)
    }
}

// MARK: - Helpers
extension InputPath {
    var isRelative: Bool { !path.hasPrefix("/") }

    var fileName: String { nsString.lastPathComponent }

    var exists: Bool { FileManager.default.fileExists(atPath: absolutePath) }

    private var nsString: NSString { path as NSString }
}

// MARK: - Absolute & Relative Paths
extension InputPath {
    var absolutePathComponents: [String] { (absolutePath as NSString).pathComponents }

    var relativePathComponents: [String] { (relativePath as NSString).pathComponents }

    /// Doesn't support paths outside project root and ".." or "." components.
    var relativePath: String {
        if isRelative {
            return path
        } else {
            return path.hasPrefix(projectRoot)
                ? path.replacingOccurrences(of: projectRoot, with: "").trimmingCharacters(in: ["/"])
                : path
        }
    }

    var absolutePath: String {
        if isRelative {
            return (projectRoot as NSString).appendingPathComponent(path)
        } else {
            return path
        }
    }
}

// MARK: - CustomStringConvertible
extension InputPath: CustomStringConvertible {
    var description: String { absolutePath }
}

// MARK: - String Conversion
extension String {
    var asInputPath: InputPath {
        if Project.projectRoot.isEmpty {
            fatalError("Project.projectRoot is not set. Please create an instance of Project first.")
        }

        return InputPath(self, projectRoot: Project.projectRoot)
    }
}
