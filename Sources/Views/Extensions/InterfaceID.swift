import struct Core.InterfaceID
import Extensions
public extension InterfaceID {
 static let none: Self = ""
 static func fromPath(_ path: some StringProtocol) -> Self {
  Self(path.split(separator: "/").joined(separator: "."))
 }
 
#if os(WASI)
 var path: String {
  rawValue.replacingOccurrences(
   of: String.period, with: String.slash
  )
 }
 #endif
}
