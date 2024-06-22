import Render
import Foundation
#if !os(WASI)
// the base domain where the source folder posts is located and
// contains the rendered html content
// must be set when rendering all posts
public var baseURL: URL!
extension [Post]: RenderableContent {
 public var base: URL {
  get {
   URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("Posts")
  }
  set { fatalError() }
 }
 
 public mutating func render(
  with renderer: some ContentRenderer<URL, Self>
 ) throws -> Self {
  try renderer.render(content: &base)
 }
}

// MARK: - Content Renderer
open class PostRenderer: ContentRenderer & ContentImporter {
 static var `default`: PostRenderer { PostRenderer() }
 /// Renders a `Post` with a complete or partial `RenderedString`
 public func render(content: inout Post) -> Post {
  content
 }
 
 public func export(content: Post) throws {}
 
 public func `import`(_ source: URL) throws -> Post {
  // let headline = source.lastPathComponent'
  // let id =  (dateCreated.formatted(.iso8601) + headline).casing(.kebab)
  // let url = source.appendingPathComponent(id, conformingTo: .html)
  fatalError()
 }
}

/// Renders formatted posts from a specific directory
open class PostsRenderer: ContentRenderer & ContentImporter {
 public func `import`(_ source: URL) throws -> Posts {
  []
 }
 
 /// Updates the current content
 public func render(content: inout Posts) -> Posts {
  content
 }
}
#endif
