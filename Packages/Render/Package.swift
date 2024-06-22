// swift-tools-version:5.9
import PackageDescription

let package = Package(
 name: "Render",
 platforms: [.macOS(.v13), .iOS(.v16)],
 products: [.library(name: "Render", targets: ["Render"])],
 dependencies: [],
 targets: [.target(name: "Render", dependencies: [])]
)