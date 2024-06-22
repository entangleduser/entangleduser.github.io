#if !canImport(SwiftUI)
import TokamakDOM

public protocol TextSelectability {
 /// A Boolean value that indicates whether the selectability type allows
 /// selection.
 ///
 /// Conforming types, such as ``EnabledTextSelectability`` and
 /// ``DisabledTextSelectability``, return `true` or `false` for this
 /// property as appropriate. SwiftUI expects this value for a given
 /// selectability type to be constant, unaffected by global state.
 static var allowsSelection: Bool { get }
}

public struct EnabledTextSelectability: TextSelectability {
 init() {}
 public static let allowsSelection: Bool = true
}

public extension TextSelectability where Self == EnabledTextSelectability {
 static var enabled: Self { Self() }
}

public struct DisabledTextSelectability: TextSelectability {
 init() {}
 public static let allowsSelection: Bool = false
}

public extension TextSelectability where Self == DisabledTextSelectability {
 static var disabled: Self { Self() }
}

public extension View {
 @ViewBuilder
 func textSelection<A: TextSelectability>(_ selectability: A) -> some View {
  if A.allowsSelection {
   self
  } else {
   HTML(
    "div",
    [
     "style":
      """
      -webkit-user-select: none; /* Safari */
      -ms-user-select: none; /* IE 10 and IE 11 */
      user-select: none; /* Standard syntax */
      """
    ],
    content: { self }
   )
  }
 }
}
#endif
