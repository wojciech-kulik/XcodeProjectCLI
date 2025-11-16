import Foundation

public struct AssetInfo {
    let fileName: String
    let darkFileName: String
    let filePath: String
    let darkFilePath: String
    let ext: String
    let directory: String
    let contentsPath: String

    init(xcassetsPath: InputPath, assetPath: String, type: AssetType = .image) {
        self.fileName = (assetPath as NSString).lastPathComponent
        self.ext = (fileName as NSString).pathExtension

        let withoutExtension = (fileName as NSString).deletingPathExtension
        self.darkFileName = "\(withoutExtension)_dark.\(ext)"

        let folderPath = (assetPath as NSString).deletingLastPathComponent

        self.directory = xcassetsPath.appending("\(folderPath)/\(withoutExtension).\(type.ext)").absolutePath
        self.filePath = "\(directory)/\(fileName)"
        self.darkFilePath = "\(directory)/\(darkFileName)"
        self.contentsPath = "\(directory)/Contents.json"
    }
}
