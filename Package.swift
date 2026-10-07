// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NamazVakti",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "NamazVakti", path: "Sources/NamazVakti")
    ]
)
