import XcodeProj

extension PBXFileElement {
    var fullPath: InputPath? {
        if Project.projectRoot.isEmpty {
            fatalError("Project.projectRoot is not set. Please create an instance of Project first.")
        }

        return try? fullPath(sourceRoot: Project.projectRoot)?.asInputPath
    }

    func setGroupSourceTree() {
        if sourceTree != .group {
            sourceTree = .group
            name = nil
            path = path?.asInputPath.lastComponent
        }

        if let group = self as? PBXGroup {
            for child in group.children {
                child.setGroupSourceTree()
            }
        }
    }
}
