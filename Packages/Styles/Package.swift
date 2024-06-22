// swift-tools-version: 5.6
import PackageDescription

let package = Package(
 name: "Styles",
 platforms: [.macOS(.v12)],
 products: [
  .library(name: "Styles", targets: ["Styles"])
 ],
 dependencies: [
  .package(url: "https://github.com/acrlc/Core.git", branch: "main")
 ],
 targets: [
  .target(
   name: "Styles",
   dependencies: [
    "Core",
    .product(name: "Extensions", package: "Core"),
    .product(name: "Components", package: "Core")
   ]
  )
 ]
)
