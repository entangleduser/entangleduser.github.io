public extension Font {
 static let header: Self = .system(size: 24)
 static let mediumHeader: Self = .system(size: 24, weight: .medium)
}

#if !canImport(SwiftUI)
struct LineLimitModifier: ViewModifier {
 @Environment(\.attributes)
 var attributes
 let limit: Int
 func body(content: Content) -> some View {
  content.environment(
   \.attributes,
   [.style: "-webkit-line-clamp: \(limit); line-clamp: \(limit);"]
   .resolvedAttributes(attributes)
  )
 }
}

public extension View {
 func lineLimit(_ max: Int) -> some View {
  HTML(
   "div",
   ["style": "-webkit-line-clamp: \(max); text-overflow: ellipsis;"],
   content: { self }
  )
 }
}
#endif
