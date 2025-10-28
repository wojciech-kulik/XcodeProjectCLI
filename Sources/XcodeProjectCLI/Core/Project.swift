import XcodeProj

final class Project {
    let targets: Targets

    private let project: XcodeProj

    init(projectPath: String) throws {
        self.project = try XcodeProj(pathString: projectPath)
        self.targets = Targets(project: project)
    }

    func save() throws {
        if let path = project.path {
            try project.write(path: path, override: true)
        }
    }
}
