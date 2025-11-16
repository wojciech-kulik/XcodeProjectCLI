import Foundation
import Testing
@testable import XcodeProject

class ProjectAssetsTests {
    let assets: ProjectAssets
    let testXCAssetsPath: String
    let testProjectPath: String
    let testResourcesPath: String
    let lightImagePath: String
    let darkImagePath: String

    init() throws {
        let projectRoot = #filePath
            .components(separatedBy: "/")
            .dropLast(4)
            .joined(separator: "/")

        self.testResourcesPath = "\(projectRoot)/TestResources/Assets"
        let testXCAssetsPath = "\(projectRoot)/.test/XcodebuildNvimApp/XcodebuildNvimApp/Assets.xcassets"
        self.testXCAssetsPath = testXCAssetsPath
        self.lightImagePath = "\(testResourcesPath)/Image.png"
        self.darkImagePath = "\(testResourcesPath)/ImageDark.png"

        self.assets = ProjectAssets(xcassetsPath: testXCAssetsPath)

        let testPath = "\(projectRoot)/.test"
        self.testProjectPath = "\(testPath)/XcodebuildNvimApp"

        try? FileManager.default.removeItem(atPath: testProjectPath)
        try FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        try FileManager.default.copyItem(atPath: "\(projectRoot)/TestResources/XcodebuildNvimApp", toPath: testProjectPath)
    }

    deinit {
        try? FileManager.default.removeItem(atPath: testProjectPath)
    }

    func expectSameFiles(at firstPath: String, and secondPath: String) throws {
        let firstData = try Data(contentsOf: URL(fileURLWithPath: firstPath))
        let secondData = try Data(contentsOf: URL(fileURLWithPath: secondPath))
        #expect(firstData == secondData)
    }
}
