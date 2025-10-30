import XcodeProj

extension PBXFileElement {
    var fullPath: InputPath? {
        if Project.projectRoot.isEmpty {
            fatalError("Project.projectRoot is not set. Please create an instance of Project first.")
        }

        return try? fullPath(sourceRoot: Project.projectRoot)?.asInputPath
    }
}
