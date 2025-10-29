import ArgumentParser
import Foundation

class ProjectTests {
    let testProjectPath: String
    let testXcodeprojPath: String

    init() throws {
        let projectRoot = #filePath
            .components(separatedBy: "/")
            .dropLast(4)
            .joined(separator: "/")

        let testPath = "\(projectRoot)/.test"
        let resourcesPath = "\(projectRoot)/TestResources"
        self.testProjectPath = "\(testPath)/XcodebuildNvimApp"
        self.testXcodeprojPath = "\(testProjectPath)/XcodebuildNvimApp.xcodeproj"

        try? FileManager.default.removeItem(atPath: testProjectPath)
        try FileManager.default.createDirectory(atPath: testPath, withIntermediateDirectories: true)
        try FileManager.default.copyItem(atPath: "\(resourcesPath)/XcodebuildNvimApp", toPath: testProjectPath)
    }

    deinit {
        try? FileManager.default.removeItem(atPath: testProjectPath)
    }

    func runTest(for command: inout some ParsableCommand) throws -> String {
        let output = try captureOutput {
            try command.run()
        }
        return output
    }

    func captureOutput(_ block: () throws -> ()) rethrows -> String {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)

        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        try block()

        fflush(stdout)
        pipe.fileHandleForWriting.closeFile()
        dup2(original, STDOUT_FILENO)
        close(original)

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

extension ProjectTests {
    enum Files {
        enum XcodebuildNvimApp {
            static let group = "XcodebuildNvimApp"
            enum Modules {
                static let group = "XcodebuildNvimApp/Modules"
                static let xcodebuildNvimApp = "XcodebuildNvimApp/Modules/XcodebuildNvimApp.swift"
                static let notAddedFile = "XcodebuildNvimApp/Modules/NotAddedFile.swift"

                enum NotAdded {
                    static let group = "XcodebuildNvimApp/Modules/NotAdded"
                }

                enum Main {
                    static let group = "XcodebuildNvimApp/Modules/Main"

                    static let contentView = "XcodebuildNvimApp/Modules/Main/ContentView.swift"
                    static let mainViewModel = "XcodebuildNvimApp/Modules/Main/MainViewModel.swift"
                }
            }
        }

        enum XcodebuildNvimAppTests {
            static let group = "XcodebuildNvimAppTests"

            static let xcodebuildNvimAppTests = "XcodebuildNvimAppTests/XcodebuildNvimAppTests.swift"
        }

        enum XcodebuildNvimAppUITests {
            static let group = "XcodebuildNvimAppUITests"

            static let xcodebuildNvimAppUITests = "XcodebuildNvimAppUITests/XcodebuildNvimAppUITests.swift"
            static let xcodebuildNvimAppUITestsLaunchTests = "XcodebuildNvimAppUITests/XcodebuildNvimAppUITestsLaunchTests.swift"
        }

        enum Helpers {
            static let group = "Helpers"

            enum GeneralUtils {
                static let group = "Helpers/GeneralUtils"
                static let randomFile = "Helpers/GeneralUtils/RandomFile.swift"

                enum Subfolder1 {
                    static let group = "Helpers/GeneralUtils/Subfolder1"
                    static let anotherFile = "Helpers/GeneralUtils/Subfolder1/CustomFile.swift"
                }

                enum Subfolder2 {
                    static let group = "Helpers/GeneralUtils/Subfolder2"
                    static let stringExtensions = "Helpers/GeneralUtils/Subfolder2/String+Extensions.swift"
                }
            }
        }

        enum EmptyTarget {}
    }
}
