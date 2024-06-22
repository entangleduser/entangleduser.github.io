@testable import Configuration
@testable import Render
@testable import UI
import XCTest

final class AppTests: XCTestCase {
 let testLog: Configuration = .log(category: "test")
 /// Test if app is able to be built on all platforms.
 /// - Note: This is useful if you don't want to run the web assembly server
 /// but still want a small greeting if you don't run into errors.
 func testBuildable() {
  testLog("Hello World!")
 }
}
