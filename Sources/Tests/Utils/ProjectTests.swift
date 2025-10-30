import ArgumentParser
import Foundation
import Testing
import XcodeProj
@testable import XcodeProjectCLI

class ProjectTests {
    let testProjectPath: String
    let testXcodeprojPath: String

    init() throws {
        let projectRoot = #filePath
            .components(separatedBy: "/")
            .dropLast(4)
            .joined(separator: "/")

        let testPath = "\(projectRoot)/.test"
        let resourcesPath = "\(projectRoot)/TestResources"
        self.testProjectPath = "\(testPath)/XcodebuildNvimApp"
        self.testXcodeprojPath = "\(testProjectPath)/XcodebuildNvimApp.xcodeproj"

        try? FileManager.default.removeItem(atPath: testProjectPath)
        try FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        try FileManager.default.copyItem(atPath: "\(resourcesPath)/XcodebuildNvimApp", toPath: testProjectPath)
        _ = try Project(projectPath: testXcodeprojPath)
    }

    deinit {
        try? FileManager.default.removeItem(atPath: testProjectPath)
    }

    func runTest(for command: inout some ParsableCommand) throws -> String {
        let output = try captureOutput {
            try command.run()
        }
        return output
    }

    func captureOutput(_ block: () throws -> ()) rethrows -> String {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)

        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        try block()

        fflush(stdout)
        pipe.fileHandleForWriting.closeFile()
        dup2(original, STDOUT_FILENO)
        close(original)

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func targets(forFile path: String) throws -> [String] {
        try Project(projectPath: testXcodeprojPath)
            .targets
            .listTargetsForFile(path.asInputPath)
            .map(\.name)
    }

    func expectFileInProject(_ filePath: InputPath) throws {
        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let files = ProjectFiles(project: project)

        #expect(filePath.exists)
        #expect(try files.findFile(filePath) != nil)
    }

    func notExpectFileInProject(_ filePath: InputPath) throws {
        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let files = ProjectFiles(project: project)

        #expect(!filePath.exists)
        #expect(try files.findFile(filePath) == nil)
    }

    func expectTargets(_ targets: [String], forFile filePath: InputPath) throws {
        let targets = try self.targets(forFile: filePath.absolutePath)
        #expect(targets == targets)
    }

    func expectGroupInProject(_ groupPath: InputPath) throws {
        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let groups = ProjectGroups(project: project)

        #expect(groupPath.exists)
        #expect(try groups.findGroup(groupPath) != nil)
    }

    func notExpectGroupInProject(_ groupPath: InputPath) throws {
        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let groups = ProjectGroups(project: project)

        #expect(!groupPath.exists)
        #expect(try groups.findGroup(groupPath) == nil)
    }
}
