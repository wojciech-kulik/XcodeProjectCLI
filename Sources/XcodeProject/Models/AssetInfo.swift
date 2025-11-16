import Foundation

public struct AssetInfo {
    let fileName: String
    let filePath: String
    let darkFileName: String
    let darkFilePath: String
    let ext: String
    let assetDirPath: String
    let parentDirectory: String
    let contentsPath: String

    init(xcassetsPath: InputPath, assetPath: String, type: AssetType = .image) {
        let fileName = (assetPath as NSString).lastPathComponent
        let ext = (fileName as NSString).pathExtension
        let withoutExtension = (fileName as NSString).deletingPathExtension
        let darkFileName = "\(withoutExtension)_dark.\(ext)"
        let assetPathWithoutLast = (assetPath as NSString).deletingLastPathComponent
        let assetDirPath = xcassetsPath.appending("\(assetPathWithoutLast)/\(withoutExtension).\(type.ext)").absolutePath
        let parentDirectory = xcassetsPath.appending(assetPathWithoutLast).absolutePath
        let darkFilePath = "\(assetDirPath)/\(darkFileName)"
        let contentsPath = "\(assetDirPath)/Contents.json"

        self.fileName = fileName
        self.filePath = "\(assetDirPath)/\(fileName)"
        self.darkFileName = darkFileName
        self.darkFilePath = darkFilePath
        self.ext = ext
        self.assetDirPath = assetDirPath
        self.parentDirectory = parentDirectory
        self.contentsPath = contentsPath
    }
}
