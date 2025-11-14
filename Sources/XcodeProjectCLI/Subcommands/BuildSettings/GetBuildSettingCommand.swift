import ArgumentParser

struct GetBuildSettingCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "get-build-setting",
        abstract: "Get a build setting for specified target in the project."
    )

    @OptionGroup
    var options: ProjectReadOptions

    @Option(help: "Target name.")
    var target: String

    @Option(
        help: "Configuration name to get the setting from. If not provided, the setting will be retrieved from the first configuration."
    )
    var config: String?

    @Option(help: "Build setting key.")
    var key: String

    func run() throws {
        let project = try Project(projectPath: options.projectPath)

        let value = try project.targets.getBuildSettingForTarget(
            target,
            config: config,
            key: key
        )
        print(value ?? "")
    }
}
