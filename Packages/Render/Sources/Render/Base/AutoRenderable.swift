public protocol AutoRenderableContent: RenderableContent {
 associatedtype Renderer: ContentRenderer<Self, RenderedContent>
 static var renderer: Renderer { get }
}

public extension AutoRenderableContent {
 func render(
  with: some ContentRenderer<BaseContent, RenderedContent>
 ) throws -> RenderedContent {
  var content = self
  return try Self.renderer.render(content: &content)
 }
 mutating func render() throws -> RenderedContent {
  try Self.renderer.render(content: &self)
 }
}
