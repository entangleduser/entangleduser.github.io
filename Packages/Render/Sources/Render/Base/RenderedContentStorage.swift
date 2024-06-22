struct RenderedContentStorage<Element> {
 typealias Elements = [String: (Any) -> Element]
 typealias Element = Elements.Element
 typealias Values = [String: (type: String, value: Any)]
 typealias Value = Values.Element
 
 /// Elements that can be converted by a named type, which defines the structure
 var elements: Elements = [:]
 /// Identifiable values that can be converted into an element
 /// if contained in `elements`
 var values: Values = [:]
 /// Adds unique elements and values to this context, omitting keys already
 /// contained
 /// 
 /// Values added should either have stable identifying string or they will be
 /// overridden.
 ///
 /// Labeling a value with a unique identifying string such as `item.element.id`
 /// can be used to avoid conflicts when processing.
 func withUniqueContext(_ context: RenderedContentStorage) -> Self {
  Self(
   elements: context.elements.merging(context.elements) { lhs, _ in lhs },
   values: context.values.merging(context.values) { lhs, _ in lhs }
  )
 }
}
