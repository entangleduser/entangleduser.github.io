#if !canImport(SwiftUI)
import Extensions
import Foundation
import struct Foundation.CharacterSet
#endif

public struct MarkdownText: View {
 let id: String?
 let verbatim: String
 #if !canImport(SwiftUI)
 @ObservedObject
 var renderer: Renderer
 public init(
  id: String,
  _ text: String
 ) {
  renderer = Renderer(id: id, text: text)
  self.id = id
  verbatim = text
 }
 #else
 public init(id: String? = nil, _ text: String) {
  self.id = id
  verbatim = text
 }
 #endif

 public var body: some View {
  #if !canImport(SwiftUI)
  ScrollView {
   HTML<String>(
    "markdown-text",
    ["class": "markdown-body"] +
     (id == nil ? .empty : ["id": id!]),
    content:
    renderer.content ??
     id == nil ? verbatim : Renderer.cache[id!] ?? verbatim
   )
   .padding([.top, .leading], 32)
   .padding([.bottom, .trailing], 29)
   .background(Color.clear)
  }
  #else
  if
   let markdown = try? AttributedString(
    markdown: verbatim,
    options: .init(
     allowsExtendedAttributes: true,
     interpretedSyntax: .inlineOnlyPreservingWhitespace
    )
   ) {
   Text(markdown.inflected())
  } else {
   Text(verbatim)
  }
  #endif
 }
}

// MARK: - Renderer
import Breakfast
extension MarkdownText {
 final class Renderer: ObservableObject {
  static var cache: [String: String] = .empty
  let id: String
  @Published
  var content: String? {
   didSet {
    if content != Self.cache[id] {
     Self.cache[id] = content
    }
   }
  }

  init(id: String, text: String) {
   defer {
    if let text = text.wrapped {
     self.content = Self.cache[id] ?? Self.renderMarkdown(text)
    }
   }
   self.id = id
  }

  public static func renderMarkdown(_ string: String) -> String {
   do {
    return try MarkdownSyntax.renderHTML(from: string)
   } catch {
    return "Markdown Error: " + error.message
   }
  }
 }
}
