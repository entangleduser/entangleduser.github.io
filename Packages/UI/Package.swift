// swift-tools-version:5.9
import PackageDescription

let package = Package(
 name: "UI",
 platforms: [.macOS(.v14)],
 products: [.library(name: "UI", targets: ["UI"])],
 dependencies: [
  .package(url: "https://github.com/acrlc/tokamak.git", branch: "main")
 ],
 targets: [
  .target(
   name: "UI", dependencies: [
    .product(
     name: "TokamakDOM",
     package: "tokamak",
     condition: .when(platforms: [.wasi])
    )
   ]
  ),
  .testTarget(name: "UITests", dependencies: ["UI"])
 ]
)
