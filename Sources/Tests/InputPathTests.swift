import Swift
import Testing
@testable import XcodeProjectCLI

@Suite("Input Path")
struct InputPathTests {
    private let projectRoot = "/Users/example/project"
    private let groupPath = "Group1/Group2"
    private let filePath = "Group1/Group2/file.swift"
    private let fullGroupPath = "/Users/example/project/Group1/Group2"
    private let fullFilePath = "/Users/example/project/Group1/Group2/file.swift"

    @Test
    func inputPath_init_shouldRemoveTrailingSlash() {
        let path = InputPath("\(groupPath)/", projectRoot: "\(projectRoot)/")

        #expect(path.absolutePath == fullGroupPath)
        #expect(path.relativePath == groupPath)
    }

    @Test
    func inputPath_isRelative_shouldReturnCorrectValue() {
        let relativePath = InputPath(filePath, projectRoot: projectRoot)
        let absolutePath = InputPath(fullGroupPath, projectRoot: projectRoot)

        #expect(relativePath.isRelative)
        #expect(!absolutePath.isRelative)
    }

    @Test
    func inputPath_fileName_shouldReturnCorrectValue() {
        let path = InputPath(filePath, projectRoot: projectRoot)

        #expect(path.fileName == "file.swift")
    }

    @Test
    func inputPath_equals_shouldReturnTrue() {
        let path1 = InputPath(filePath, projectRoot: projectRoot)
        let path2 = InputPath(fullFilePath, projectRoot: projectRoot)

        #expect(path1 == path2)
    }

    @Test
    func inputPath_directory_shouldReturnCorrectPath() {
        let path = InputPath(filePath, projectRoot: projectRoot)

        #expect(path.directory.relativePath == groupPath)
        #expect(path.directory.absolutePath == fullGroupPath)
    }

    @Test
    func inputPath_parent_shouldReturnCorrectPath_whenGroupIsProvided() {
        let path = InputPath(groupPath, projectRoot: projectRoot)

        #expect(path.parent?.relativePath == "Group1")
    }

    @Test
    func inputPath_parent_shouldReturnCorrectPath_whenCalledTwice() {
        let path = InputPath("Group1/Group2/Group3", projectRoot: projectRoot)

        #expect(path.parent?.relativePath == "Group1/Group2")
        #expect(path.parent?.parent?.relativePath == "Group1")
        #expect(path.parent?.parent?.absolutePath == "\(projectRoot)/Group1")
    }

    @Test
    func inputPath_parent_shouldReturnCorrectPath_whenFileIsProvided() {
        let path = InputPath(filePath, projectRoot: projectRoot)

        #expect(path.parent?.relativePath == groupPath)
    }

    @Test
    func inputPath_parent_shouldReturnNil_whenLastComponent() {
        let path = InputPath("/Users", projectRoot: "/")

        #expect(path.parent?.absolutePath == "/")
        #expect(path.parent?.relativePath == "")
        #expect(path.parent?.parent == nil)
    }

    @Test
    func inputPath_absolutePathComponents_shouldReturnCorrectComponents() {
        let path = InputPath(filePath, projectRoot: projectRoot)

        #expect(path.absolutePathComponents == ["/", "Users", "example", "project", "Group1", "Group2", "file.swift"])
    }

    @Test
    func inputPath_relativePathComponents_shouldReturnCorrectComponents() {
        let path = InputPath(filePath, projectRoot: projectRoot)

        #expect(path.relativePathComponents == ["Group1", "Group2", "file.swift"])
    }

    @Test
    func inputPath_absolutePath_shouldReturnCorrectPath() {
        let path1 = InputPath(filePath, projectRoot: projectRoot)
        let path2 = InputPath(fullFilePath, projectRoot: projectRoot)

        #expect(path1.absolutePath == fullFilePath)
        #expect(path2.absolutePath == fullFilePath)
    }

    @Test
    func inputPath_relativePath_shouldReturnCorrectPath() {
        let path1 = InputPath(filePath, projectRoot: projectRoot)
        let path2 = InputPath(fullFilePath, projectRoot: projectRoot)

        #expect(path1.relativePath == filePath)
        #expect(path2.relativePath == filePath)
    }
}
