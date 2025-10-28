import XcodeProj

extension PBXGroup {
    func listAllGroups() throws -> [PBXGroup] {
        var allGroups: [PBXGroup] = []

        for group in children.compactMap({ $0 as? PBXGroup }) {
            allGroups.append(group)
            try allGroups.append(contentsOf: group.listAllGroups())
        }
        return allGroups
    }
}
