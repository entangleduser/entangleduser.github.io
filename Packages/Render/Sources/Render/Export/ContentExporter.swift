public protocol ContentExporter<Content> {
 associatedtype Content
 func export(content: Content) throws
}
