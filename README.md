[![GitHub Release](https://img.shields.io/github/v/release/wojciech-kulik/XcodeProjectCLI?color=8A2BE2)](https://github.com/wojciech-kulik/XcodeProjectCLI/releases)
[![min macOS](https://img.shields.io/badge/macOS-13.0+-silver)](#)
[![CI Status](https://img.shields.io/github/actions/workflow/status/wojciech-kulik/XcodeProjectCLI/build-and-test.yml)](https://github.com/wojciech-kulik/XcodeProjectCLI/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/wojciech-kulik/XcodeProjectCLI/graph/badge.svg?token=KYAVYEWYU6)](https://codecov.io/gh/wojciech-kulik/XcodeProjectCLI)

# XcodeProjectCLI

A fast, lightweight command-line tool for managing Xcode projects - built entirely in Swift.

Easily integrate it into your development workflow or automate complex refactoring tasks with just a few commands.

💚 Powered by the excellent [XcodeProj](https://github.com/tuist/XcodeProj) library from [Tuist](https://github.com/tuist).

## 🚀 Features

```
OVERVIEW: XcodeProjectCLI

USAGE: xcp <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

TARGET SUBCOMMANDS:
  list-targets            List project targets.
  set-target              Set target for an existing file.

GROUP SUBCOMMANDS:
  add-group               Add a group to the project.
  delete-group            Delete a group from the project.
  move-group              Move a group to a different location within the project.
  rename-group            Rename a group within the project.

FILE SUBCOMMANDS:
  add-file                Add a file to specified targets in the project.
  delete-file             Delete a file from the project.
  move-file               Move a file to a different location within the project.
  rename-file             Rename a file within the project.

  See 'xcp help <subcommand>' for detailed help.
```

## ⏳ In Progress

Planned features:

- [ ] Simple build settings management
- [ ] Synchronized folder commands

## 📦 Installation

```bash
brew install wojciech-kulik/tap/xcp
```

## 🛠️ Building from Source

1. Clone the repository.
2. Navigate to the project directory.
3. Build the project and install:

   ```bash
   make install
   ```

4. Verify the installation:

   ```bash
   xcp --version
   ```

## 🤓 My Other Projects

- [Snippety](https://snippety.app) - Snippets manager for macOS & iOS
- [FlashSpace](https://github.com/wojciech-kulik/FlashSpace) - Fast virtual workspace manager for macOS
- [Smog Poland](https://smog-polska.pl) - Air quality monitoring app for Poland
- [xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim) - Neovim plugin for building Xcode projects

[xcodebuild.nvim]: https://github.com/wojciech-kulik/xcodebuild.nvim
