import ArgumentParser
import XcodeProject

public struct SetBuildSettingCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "set-build-setting",
        abstract: "Set build setting."
    )

    @OptionGroup
    var options: ProjectReadOptions

    @Option(help: "Comma separated list of target names. If not provided, the setting will be applied to all targets.")
    var targets: String?

    @Option(
        help: "Comma separated list of build configurations to apply the setting to. If not provided, the setting will be applied to all configurations."
    )
    var configs: String?

    @Flag(help: "If set, the setting will be appended to existing values instead of replacing them.")
    var append = false

    @Option(help: "Build setting key.")
    var key: String

    @Option(help: "Build setting value.")
    var value: String

    private var parsedTargets: [String] = []
    private var parsedConfigs: [String] = []

    public init() {}

    public func run() throws {
        let project = try Project(xcodeProjectPath: options.projectPath)

        let targets = parsedTargets.isNotEmpty
            ? parsedTargets
            : project.targets.listTargets().map(\.name)

        try project.targets.setBuildSettingsForTarget(
            targets,
            configs: parsedConfigs,
            settings: [key: value],
            append: append
        )

        try project.save()
    }

    public mutating func validate() throws {
        let targets = targets?.components(separatedBy: ",").filter { !$0.isEmpty }
        parsedTargets = targets ?? []

        let configs = configs?.components(separatedBy: ",").filter { !$0.isEmpty }
        parsedConfigs = configs ?? []
    }
}
