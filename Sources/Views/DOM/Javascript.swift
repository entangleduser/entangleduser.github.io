#if !canImport(SwiftUI)
import JavaScriptKit
import struct Foundation.UUID
extension UUID: ConvertibleToJSValue {
 public var jsValue: JavaScriptKit.JSValue {
  .string(uuidString)
 }
}

import struct Core.InterfaceID
extension InterfaceID: ConvertibleToJSValue {
 public var jsValue: JavaScriptKit.JSValue {
  .string(rawValue)
 }
}
#endif
