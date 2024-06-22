// swift-tools-version:5.9
import PackageDescription

let package = Package(
 name: "entangleduser.github.io",
 platforms: [.macOS(.v14)],
 products: [
  .executable(name: "App", targets: ["App"])
 ],
 dependencies: [
  .package(url: "https://github.com/acrlc/Core", branch: "main"),
  .package(url: "https://github.com/acrlc/Configuration.git", branch: "main"),
  .package(path: "Packages/UI"),
  .package(path: "Packages/Render"),
  .package(path: "Packages/Styles"),
  .package(
   url: "https://github.com/entangleduser/Breakfast.git", branch: "main"
  ),
  .package(url: "https://github.com/acrlc/Acrylic.git", branch: "main"),
  .package(path: "~/.git/acrlc/swift-shell"),
//  .package(url: "https://github.com/acrlc/swift-shell", branch: "main"),
  .package(url: "https://github.com/swiftwasm/carton", branch: "main")
 ],
 targets: [
  // MARK: - App -
  .executableTarget(
   name: "App",
   dependencies: [
    "Core",
    .product(name: "Extensions", package: "Core"),
    "Configuration",
    "Acrylic",
    "Views",
    "Posts"
   ],
   resources: [
    .process("Resources/CSS"),
    .process("Resources/Markdown")
   ]
  ),
  // MARK: - Content -
  .target(
   name: "Posts",
   dependencies: [
    "Core",
    .product(name: "Extensions", package: "Core"), "Render"
   ]
  ),
  // MARK: - Views -
  .target(
   name: "Views",
   dependencies: [
    "Core",
    .product(name: "Extensions", package: "Core"),
    "UI",
    "Styles",
    "Breakfast"
   ]
  ),
  .testTarget(name: "AppTests", dependencies: ["Configuration", "Render", "UI"])
 ]
)
