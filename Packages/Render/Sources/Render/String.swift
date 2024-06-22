import struct Foundation.Data
public struct RenderedString<Content>: RenderableContent {
 public static var empty: Self { Self() }
 public enum Element {
  case string(String),
       stringConvertible(id: String? = nil, element: String, string: String),
       dataConvertible(id: String? = nil, element: String, data: Data)
 }

 public var base = String()
 public var contents: [Element] = []

 public mutating func render(
  with render: some ContentRenderer<String, Self>
 ) -> Self {
  self
 }
}
