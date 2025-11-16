import XcodeProj

extension PBXNativeTarget {
    /// Returns all files in the target's build phases (including resources).
    func allFiles() throws -> [PBXFileElement] {
        try (sourceFiles() + (resourcesBuildPhase()?.files?.compactMap(\.file) ?? []))
    }
}
