import XcodeProj

extension XcodeProj {
    var rootDir: String {
        path?.parent().string ?? ""
    }
}
