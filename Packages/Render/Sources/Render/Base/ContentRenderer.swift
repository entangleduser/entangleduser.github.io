public protocol ContentRenderer<Content, RenderedContent> {
 associatedtype Content
 associatedtype RenderedContent
 func render(content: inout Content) throws -> RenderedContent
}
