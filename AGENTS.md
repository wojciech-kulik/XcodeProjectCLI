# Agent Guidelines for XcodeProjectCLI

## Build & Test Commands
- **Build**: `swift build` (release: `swift build -c release`)
- **Test all**: `swift test`
- **Test single**: `swift test --filter <TestName>` (e.g., `swift test --filter AddFileCommandTests`)
- **Lint**: SwiftFormat configured via `.swiftformat`, SwiftLint via `.swiftlint.yml`
- **Format**: `swiftformat .` (if installed)

## Code Style
- **Swift version**: 5.9+, macOS 13+
- **Indentation**: 4 spaces, max line length 130 (SwiftFormat) / 160 (SwiftLint)
- **Imports**: Foundation/XcodeProj only when needed, no unused imports
- **Types**: Use explicit types for properties, inference for local vars
- **Naming**: camelCase for vars/funcs, PascalCase for types, descriptive names (min 1 char allowed)
- **Error handling**: Use `CLIError` enum with descriptive messages, throw for expected errors
- **Extensions**: Group by functionality, no imports if extending stdlib types
- **Testing**: Use Swift Testing framework (`import Testing`), organize in `SerializedSuite`, use `#expect`
- **Commands**: Use ArgumentParser, group options with `@OptionGroup`, validate inputs in `validate()`
- **Formatting**: Allman false, inline commas, no space in ranges, `void` as tuple `()`, `self` in init only

## Project Structure
- Core logic in `Core/`, commands in `Subcommands/`, extensions in `Extensions/`, models in `Models/`
- Test resources in `TestResources/`, use `ProjectTests` base class for serialized test execution
