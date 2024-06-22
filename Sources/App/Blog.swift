@_exported import Acrylic
import Configuration
@_exported import Core
#if os(WASI)
import JavaScriptEventLoop
import JavaScriptKit
#else
import class Foundation.Bundle
#endif
import Views

/// The main object that is used throughout the app to facilitate basic
/// functionality for all platforms.
@dynamicMemberLookup
final class Blog: ObservableModule {
 static var shared = Blog()
 subscript<A>(dynamicMember keyPath: KeyPath<Configuration, A>) -> A {
  configuration[keyPath: keyPath]
 }

 let configuration: Configuration = .default(
  id: "entangleduser.blog", formal: "entangledUser"
 )

 lazy var log = configuration

 @Published
 var interface: InterfaceID = .home
 var title: String { "William Luke" }

 #if os(WASI)
 func addLocationHandler() {
  log("Adding location handler", with: .info)
  let locationHandler = JSClosure { _ in
   let window = JSObject.global.window
   guard
    var location = window.location.pathname.jsValue.string?
     .removingAll(where: { $0.isWhitespace })
   else {
    self.log(
     "location for window couldn't be found!",
     for: .fault
    )
    return .null
   }

   location.remove(while: { $0 == .slash })

   self.log("Initial location is \(location.readable)")

   func `default`() -> JSValue {
    self.interface = .none
    return .undefined
   }

   let excluded = "index.html"
   if location.isEmpty || location == excluded {
    return `default`()
   }

   if location.hasSuffix(excluded) {
    #if DEBUG
    let endIndex = location.index(location.endIndex, offsetBy: -11)
    self
     .log("Trimming \(location) to \(String(location[..<endIndex]).readable)")
    #endif

    location.removeLast(11)

    #if DEBUG
    self.log("Trimmed location is \(location.readable)")
    #endif
   }

   if location.isEmpty {
    return `default`()
   }

   let id: InterfaceID = .fromPath(location)

   #if DEBUG
   self.log("Interface id is \(id)")
   #endif
   window.history.replaceState(
    window.undefined, "", id.path
   ).function?.callAsFunction()

   self.interface = id

   return .undefined
  }

  var window = JSObject.global.window
  window.onpopstate = .object(locationHandler)
  // perform initial location check
  locationHandler()
 }

 #endif

 var void: some Module {
  Perform.Async {
   #if os(WASI)
   addLocationHandler()
   #endif
  }
 }
}

#if os(WASI)
extension String {
 init(fileName: String) async throws {
  let fetchObject = JSObject.global.fetch.function!
  func fetch(_ url: String) -> JSPromise {
   JSPromise(fetchObject(url).object!)!
  }

  let response = try await fetch(fileName).value
  let text = try await JSPromise(response.text().object!)!.value
  self = try text.string.throwing(
   reason: """
   The file '\(fileName)' couldn't be fetched using javascript! \

   Make sure that it's processed as SPM resource or copied within your bundle \
   under the resources folder.
   """
  )
 }
}
#endif
