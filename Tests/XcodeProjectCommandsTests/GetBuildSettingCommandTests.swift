import Testing
@testable import XcodeProject
@testable import XcodeProjectCommands

extension SerializedSuite {
    @Suite("Get Build Setting Command", .serialized)
    final class GetBuildSettingCommandTests: ProjectTests {}
}

extension SerializedSuite.GetBuildSettingCommandTests {
    @Test
    func getBuildSetting_shouldReturnEmptyString_whenSettingNotFound() throws {
        var sut = try GetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--target",
            "XcodebuildNvimApp",
            "--key",
            "CUSTOM_SETTING"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")
    }

    @Test
    func getBuildSetting_shouldReturnStringValue() throws {
        var sut = try GetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--target",
            "XcodebuildNvimApp",
            "--key",
            "PRODUCT_NAME"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "$(TARGET_NAME)")
    }

    @Test(arguments: [("Debug", "YES"), ("Release", "NO")])
    func getBuildSetting_shouldReturnStringValueForEachConfig(value: (String, String)) throws {
        var sut = try GetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--target",
            "XcodebuildNvimApp",
            "--config",
            value.0,
            "--key",
            "ENABLE_PREVIEWS"
        ])

        let output = try runTest(for: &sut)
        #expect(output == value.1)
    }

    @Test
    func getBuildSetting_shouldReturnBoolValue() throws {
        var sut = try GetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--target",
            "XcodebuildNvimApp",
            "--key",
            "GENERATE_INFOPLIST_FILE"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "YES")
    }

    @Test
    func getBuildSetting_shouldReturnArray() throws {
        var sut = try GetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--target",
            "XcodebuildNvimApp",
            "--key",
            "LD_RUNPATH_SEARCH_PATHS"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "$(inherited)\n@executable_path/Frameworks")
    }

    @Test
    func getBuildSetting_shouldThrowError_whenTargetNotFound() throws {
        let sut = try GetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--target",
            "NonExistentTarget",
            "--key",
            "PRODUCT_NAME"
        ])

        #expect(throws: XcodeProjectError.missingTargets(["NonExistentTarget"])) {
            try sut.run()
        }
    }

    @Test
    func getBuildSetting_shouldThrowError_whenConfigNotFound() throws {
        let sut = try GetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--target",
            "XcodebuildNvimApp",
            "--config",
            "NonExistentConfig",
            "--key",
            "PRODUCT_NAME"
        ])

        #expect(throws: XcodeProjectError.buildConfigurationNotFound("NonExistentConfig")) {
            try sut.run()
        }
    }
}
