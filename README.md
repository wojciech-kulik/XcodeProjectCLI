# XcodeProjectCLI

A fast, lightweight command-line tool for managing Xcode projects - built entirely in Swift.

Easily integrate it into your development workflow or automate complex refactoring tasks with just a few commands.

💚 Powered by the excellent [XcodeProj](https://github.com/tuist/XcodeProj) library from [Tuist](https://github.com/tuist).

> [!WARNING]
> This project is currently a work in progress.
> 
> It's being developed primarily as a Swift-based replacement for the Ruby helper used in the [xcodebuild.nvim]
 plugin. However, the design aims to remain flexible enough to accommodate a wide range of use cases.

## 🚀 Features

```
OVERVIEW: XcodeProjectCLI

USAGE: xcodeproj <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

TARGET SUBCOMMANDS:
  list-targets            List project targets.
  set-target              Set target for an existing file.

FILE SUBCOMMANDS:
  add-file                Add a file to specified targets in the project.
  delete-file             Delete a file from the project.
  move-file               Move a file to a different location within the project.
  rename-file             Rename a file within the project.

  See 'xcodeproj help <subcommand>' for detailed help.
```

## 📦 Installation

Right now, you need to build the project from source.

1. Clone the repository.
2. Navigate to the project directory.
3. Build the project:

   ```bash
   swift build -c release
   ```

4. The built executable will be located in the `.build/release` directory. You
   can copy it to a directory in your PATH for easier access:

   ```bash
    cp .build/release/XcodeProjectCLI /usr/local/bin/xcodeproj
   ```

## 🤓 My Other Projects

- [Snippety](https://snippety.app) - Snippets manager for macOS & iOS
- [FlashSpace](https://github.com/wojciech-kulik/FlashSpace) - Fast virtual workspace manager for macOS
- [Smog Poland](https://smog-polska.pl) - Air quality monitoring app for Poland
- [xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim) - Neovim plugin for building Xcode projects
  

[xcodebuild.nvim]: https://github.com/wojciech-kulik/xcodebuild.nvim
