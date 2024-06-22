import XCTest

final class UITests: XCTestCase {
 /// Run app on main thread to avoid any warnings within a framework
 @MainActor
 func test() {
  FirstApp.main()
 }
}

// MARK: - Impementation
// import public interface, tests should be able to compile without compiler
// macros
import UI

struct FirstApp: App {
 var body: some Scene {
  WindowGroup {
   Text("Hello World!")
  }
 }
}
