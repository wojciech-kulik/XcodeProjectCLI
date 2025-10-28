import XcodeProj

final class Groups {
    private let project: XcodeProj

    init(project: XcodeProj) {
        self.project = project
    }

    func listAllGroups() throws -> [(group: PBXGroup, fullPath: String)] {
        try project.pbxproj.rootGroup()?
            .listAllGroups()
            .compactMap {
                guard let path = try $0.fullPath(sourceRoot: project.rootDir) else { return nil }
                return ($0, path)
            } ?? []
    }

    func findGroup(byFullPath fullPath: String) throws -> PBXGroup? {
        try listAllGroups()
            .first { _, groupFullPath in
                groupFullPath == fullPath || fullPath == "\(groupFullPath)/"
            }?
            .group
    }
}
