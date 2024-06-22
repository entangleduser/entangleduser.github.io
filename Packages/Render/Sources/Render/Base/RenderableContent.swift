public protocol RenderableContent<BaseContent, RenderedContent> {
 associatedtype BaseContent
 associatedtype RenderedContent
 var base: BaseContent { get set }
 mutating func render(with: some ContentRenderer<BaseContent, Self>) throws
  -> RenderedContent
}

extension RenderableContent where BaseContent: RenderableContent {
 public mutating func render(
  with renderer: some ContentRenderer<BaseContent, Self>
 ) throws -> Self {
  try renderer.render(content: &base)
 }
}
