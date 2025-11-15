/*
 Sample Xcode Project Structure
 (TestResources/XcodebuildNvimApp/XcodebuildNvimApp.xcodeproj)

 - XcodebuildNvimApp
   - Modules
     - XcodebuildNvimApp.swift
     - NotAddedFile.swift
     - NotAdded
       - NotAddedFile.swift
     - Main
       - ContentView.swift
       - MainViewModel.swift
 - XcodebuildNvimAppTests
     - XcodebuildNvimAppTests.swift
 - XcodebuildNvimAppUITests
     - XcodebuildNvimAppUITests.swift
     - XcodebuildNvimAppUITestsLaunchTests.swift
 - Helpers
     - NotAddedFile.swift
     - GeneralUtils
         - RandomFile.swift [targets: Helpers, XcodebuildNvimApp, XcodebuildNvimAppTests]
         - NotAddedFile.swift
         - Subfolder1
             - CustomFile.swift [targets: Helpers, XcodebuildNvimApp]
         - Subfolder2
             - String+Extensions.swift [targets: Helpers, XcodebuildNvimApp]
         - NotAdded
             - NotAddedFile.swift
             - NotAdded
                 - NotAddedFile.swift
 - EmptyTarget
 */

enum Files {
    enum XcodebuildNvimApp {
        static let group = "XcodebuildNvimApp"
        enum Modules {
            static let group = "XcodebuildNvimApp/Modules"
            static let xcodebuildNvimApp = "XcodebuildNvimApp/Modules/XcodebuildNvimApp.swift"
            static let notAddedFile = "XcodebuildNvimApp/Modules/NotAddedFile.swift"

            enum NotAdded {
                static let group = "XcodebuildNvimApp/Modules/NotAdded"
                static let notAddedFile = "XcodebuildNvimApp/Modules/NotAdded/NotAddedFile.swift"
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
        static let notAddedFile = "Helpers/NotAddedFile.swift"

        enum GeneralUtils {
            static let group = "Helpers/GeneralUtils"
            static let randomFile = "Helpers/GeneralUtils/RandomFile.swift"
            static let notAddedFile = "Helpers/GeneralUtils/NotAddedFile.swift"

            enum Subfolder1 {
                static let group = "Helpers/GeneralUtils/Subfolder1"
                static let customFile = "Helpers/GeneralUtils/Subfolder1/CustomFile.swift"
            }

            enum Subfolder2 {
                static let group = "Helpers/GeneralUtils/Subfolder2"
                static let stringExtensions = "Helpers/GeneralUtils/Subfolder2/String+Extensions.swift"
            }

            enum NotAdded {
                static let group = "Helpers/GeneralUtils/NotAdded"
                static let notAddedFile = "Helpers/GeneralUtils/NotAdded/NotAddedFile.swift"

                enum NotAdded {
                    static let group = "Helpers/GeneralUtils/NotAdded/NotAdded"
                    static let notAddedFile = "Helpers/GeneralUtils/NotAdded/NotAdded/NotAddedFile.swift"
                }
            }
        }
    }

    enum EmptyTarget {}
}
