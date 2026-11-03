// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HumorMeCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [.library(name: "HumorMeCore", targets: ["HumorMeCore"])],
    targets: [
        .target(name: "HumorMeCore", path: "HumorMe", exclude: ["Services/AppStore.swift", "Views", "Resources", "Config.plist", "HumorMeApp.swift"], sources: ["Models/Models.swift", "Services/APIClient.swift"]),
        .testTarget(name: "HumorMeCoreTests", dependencies: ["HumorMeCore"], path: "Tests")
    ]
)
