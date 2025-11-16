import Foundation

public enum PathUtils {
    public static func processWorkingDirectory() -> String? {
        let pwd = ProcessInfo.processInfo.environment["PWD"]
        var currentDir = pwd

        #if DEBUG
        if pwd == nil || pwd == "/tmp" {
            currentDir = #filePath
                .components(separatedBy: "/")
                .dropLast(4)
                .joined(separator: "/")
        }
        #endif

        return currentDir
    }

    public static func toAbsolutePath(_ path: String) -> String {
        var result = path

        if let currentDir = processWorkingDirectory(), !(path as NSString).isAbsolutePath {
            result = ("\(currentDir)/\(path)" as NSString).standardizingPath
        }

        return (result as NSString).expandingTildeInPath
    }
}
