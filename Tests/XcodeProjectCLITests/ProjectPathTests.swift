import Foundation
import Testing
@testable import XcodeProject
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Project Path", .serialized)
    final class ProjectPathTests: ProjectTests {
        let file = Files.XcodebuildNvimApp.Modules.Main.mainViewModel
        let relativePath = ".test/XcodebuildNvimApp/XcodeBuildNvimApp.xcodeproj"
        let dotPath = "../XcodeProjectCLI/.test/XcodebuildNvimApp/XcodeBuildNvimApp.xcodeproj"

        var tildePath: String {
            testXcodeprojPath.replacingOccurrences(
                of: NSHomeDirectory(),
                with: "~"
            )
        }
    }
}

extension SerializedSuite.ProjectPathTests {
    @Test
    func projectPath_shouldListTargets_whenPathContainsDots() throws {
        var sut = try ListTargetsCommand.parse([
            dotPath,
            "--file",
            file
        ])

        let output = try runTest(for: &sut)

        #expect(output == ["XcodebuildNvimApp"])
    }

    @Test
    func projectPath_shouldListTargets_whenPathContainsTilde() throws {
        var sut = try ListTargetsCommand.parse([
            tildePath,
            "--file",
            file
        ])

        let output = try runTest(for: &sut)

        #expect(output == ["XcodebuildNvimApp"])
    }

    @Test
    func projectPath_shouldListTargets_whenPathIsRelative() throws {
        var sut = try ListTargetsCommand.parse([
            relativePath,
            "--file",
            file
        ])

        let output = try runTest(for: &sut)

        #expect(output == ["XcodebuildNvimApp"])
    }

    @Test
    func projectPath_shouldListTargets_whenPathIsAbsolute() throws {
        var sut = try ListTargetsCommand.parse([
            testXcodeprojPath,
            "--file",
            file
        ])

        let output = try runTest(for: &sut)

        #expect(output == ["XcodebuildNvimApp"])
    }
}
