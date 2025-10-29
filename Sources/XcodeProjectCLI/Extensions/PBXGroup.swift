import Foundation
import XcodeProj

extension PBXGroup {
    func allNestedGroups() throws -> [PBXGroup] {
        var allGroups: [PBXGroup] = []

        for child in children.compactMap({ $0 as? PBXGroup }) {
            allGroups.append(child)
            try allGroups.append(contentsOf: child.allNestedGroups())
        }

        return allGroups
    }

    func subgroup(named name: String) -> PBXGroup? {
        children
            .compactMap { $0 as? PBXGroup }
            .first { $0.path?.asInputPath.fileName == name }
    }
}
