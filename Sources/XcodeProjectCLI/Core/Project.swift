import XcodeProj

final class Project {
    let targets: Targets

    private let project: XcodeProj

    init(projectPath: String) throws {
        self.project = try XcodeProj(pathString: projectPath)
        self.targets = Targets(project: project)
    }
}
