import Testing
import XcodeProj
@testable import XcodeProject
@testable import XcodeProjectCLI

extension SerializedSuite {
    @Suite("Set Build Setting Command", .serialized)
    final class SetBuildSettingCommandTests: ProjectTests {
        let allConfigs = ["Debug", "Release"]
        let allTargets = [
            "XcodebuildNvimApp",
            "Helpers",
            "XcodebuildNvimAppTests",
            "XcodebuildNvimAppUITests",
            "EmptyTarget"
        ]
    }
}

extension SerializedSuite.SetBuildSettingCommandTests {
    @Test
    func setBuildSetting_shouldSetStringValue() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--key",
            "CUSTOM_SETTING",
            "--value",
            "MyValue"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for target in allTargets {
            for config in allConfigs {
                let setting: String? = try getSetting(
                    for: target,
                    config: config,
                    key: "CUSTOM_SETTING"
                )
                #expect(setting == "MyValue")
            }
        }

        try validateProject()
    }

    @Test
    func setBuildSetting_shouldAppendStringValue() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--key",
            "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS",
            "--value",
            "gnu++23",
            "--append"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for config in allConfigs {
            let setting: String? = try getSetting(
                for: "Helpers",
                config: config,
                key: "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS"
            )
            #expect(setting == "gnu17 gnu++20 gnu++23")
        }

        try validateProject()
    }

    @Test
    func setBuildSetting_shouldSetIntValue() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--key",
            "CUSTOM_SETTING",
            "--value",
            "1"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for target in allTargets {
            for config in allConfigs {
                let setting: String? = try getSetting(
                    for: target,
                    config: config,
                    key: "CUSTOM_SETTING"
                )
                #expect(setting == "1")
            }
        }

        try validateProject()
    }

    @Test(arguments: ["true", "YES"])
    func setBuildSetting_shouldSetBoolValueToTrue(value: String) throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--key",
            "CUSTOM_SETTING",
            "--value",
            value
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for target in allTargets {
            for config in allConfigs {
                let setting: String? = try getSetting(
                    for: target,
                    config: config,
                    key: "CUSTOM_SETTING"
                )
                #expect(setting == "YES")
            }
        }

        try validateProject()
    }

    @Test(arguments: ["false", "NO"])
    func setBuildSetting_shouldSetBoolValueToFalse(value: String) throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--key",
            "CUSTOM_SETTING",
            "--value",
            value
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for target in allTargets {
            for config in allConfigs {
                let setting: String? = try getSetting(
                    for: target,
                    config: config,
                    key: "CUSTOM_SETTING"
                )
                #expect(setting == "NO")
            }
        }

        try validateProject()
    }

    @Test
    func setBuildSetting_shouldAppendArrayItem() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--key",
            "LD_RUNPATH_SEARCH_PATHS",
            "--value",
            "customPath",
            "--append"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for config in allConfigs {
            let setting: [String]? = try getSetting(
                for: "XcodebuildNvimApp",
                config: config,
                key: "LD_RUNPATH_SEARCH_PATHS"
            )
            #expect(setting == [
                "$(inherited)",
                "@executable_path/Frameworks",
                "customPath"
            ])
        }

        try validateProject()
    }

    @Test
    func setBuildSetting_shouldReplaceArray() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--key",
            "LD_RUNPATH_SEARCH_PATHS",
            "--value",
            "customPath"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for config in allConfigs {
            let setting: [String]? = try getSetting(
                for: "XcodebuildNvimApp",
                config: config,
                key: "LD_RUNPATH_SEARCH_PATHS"
            )
            #expect(setting == ["customPath"])
        }

        try validateProject()
    }

    @Test
    func setBuildSetting_shouldSetValueForSelectedTargets() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--targets",
            "XcodebuildNvimApp,Helpers",
            "--key",
            "CUSTOM_SETTING",
            "--value",
            "MyValue"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        let targets = ["XcodebuildNvimApp", "Helpers"]
        let targetsWithoutSetting = Set(allTargets).subtracting(targets)

        for target in targets {
            for config in allConfigs {
                let setting: String? = try getSetting(
                    for: target,
                    config: config,
                    key: "CUSTOM_SETTING"
                )
                #expect(setting == "MyValue")
            }
        }

        for target in targetsWithoutSetting {
            for config in allConfigs {
                let setting: String? = try getSetting(
                    for: target,
                    config: config,
                    key: "CUSTOM_SETTING"
                )
                #expect(setting == nil)
            }
        }

        try validateProject()
    }

    @Test
    func setBuildSetting_shouldSetValueForSelectedConfigurations() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--configs",
            "Debug",
            "--key",
            "CUSTOM_SETTING",
            "--value",
            "MyValue"
        ])

        let output = try runTest(for: &sut)
        #expect(output == "")

        for target in allTargets {
            let settingDebug: String? = try getSetting(
                for: target,
                config: "Debug",
                key: "CUSTOM_SETTING"
            )
            #expect(settingDebug == "MyValue")

            let settingRelease: String? = try getSetting(
                for: target,
                config: "Release",
                key: "CUSTOM_SETTING"
            )
            #expect(settingRelease == nil)
        }

        try validateProject()
    }

    @Test
    func setBuildSetting_shouldThrowErrorForMissingTarget() throws {
        var sut = try SetBuildSettingCommand.parse([
            testXcodeprojPath,
            "--targets",
            "XcodebuildNvimApp,NonExistentTarget",
            "--key",
            "CUSTOM_SETTING",
            "--value",
            "MyValue"
        ])

        #expect(throws: XcodeProjectError.missingTargets(["NonExistentTarget"])) {
            _ = try runTest(for: &sut)
        }
    }

    private func getSetting<T>(for targetName: String, config: String, key: String) throws -> T? {
        let project = try XcodeProj(path: .init(testXcodeprojPath))
        let target = project.pbxproj.targets(named: targetName)
        let buildConfig = target.first?.buildConfigurationList?.buildConfigurations.first {
            $0.name == config
        }

        return buildConfig?.buildSettings[key] as? T
    }
}
