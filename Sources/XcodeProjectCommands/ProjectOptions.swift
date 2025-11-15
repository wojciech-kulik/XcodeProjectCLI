import ArgumentParser

struct ProjectWriteOptions: ParsableArguments {
    @Argument(help: .init(
        "xcodeproj path, if not provided will search in the current directory",
        valueName: "xcode-project"
    ))
    var projectPath: String?

    @Flag(
        help: "If set, only update the project file without performing any disk operations (creating, moving, deleting files/folders)."
    )
    var projectOnly = false
}

struct ProjectReadOptions: ParsableArguments {
    @Argument(help: .init(
        "xcodeproj path, if not provided will search in the current directory",
        valueName: "xcode-project"
    ))
    var projectPath: String?
}
