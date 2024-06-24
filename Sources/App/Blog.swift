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
final class Blog {
 static let shared = Blog()
 subscript<A>(dynamicMember keyPath: KeyPath<Configuration, A>) -> A {
  configuration[keyPath: keyPath]
 }

 let configuration: Configuration = .default(
  id: "entangleduser.blog", formal: "entangledUser"
 )

 lazy var log = configuration

 var title: String { "William Luke" }

 func load() {
  #if os(WASI)
  JavaScriptEventLoop.installGlobalExecutor()
  #endif
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
