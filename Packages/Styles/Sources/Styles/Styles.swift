import Extensions
import Core

public protocol StyleProperty: OptionalStringConvertible, RawRepresentable
where RawValue == String {
 /// The name of the property, the object name by default
 var name: String { get }
 /// rawValue: The formatted value of the property as read by a style sheet
}

public extension StyleProperty {
 init?(rawValue: String) { fatalError() }

 static var name: String {
  String(describing: Self.self)
   .inserting(
    separator: "-",
    where: { $0.isUppercase || $0 == .period },
    transforming: {
     if $0 == .period { return Character("") }
     else { return Character($0.lowercased()) }
    }
   )
 }

 var name: String { Self.name }
 var description: String? {
  rawValue.isEmpty ? nil : "\(self.name): \(rawValue);"
 }
}

/// A tag that can build a single style based on css selectors
public struct Style:
 ExpressibleAsEmpty,
 ExpressibleByStringLiteral,
 ExpressibleByArrayLiteral,
 ExpressibleByDictionaryLiteral,
 CustomStringConvertible {
 public init() {}
 public static var empty: Self { Self() }
 public var isEmpty: Bool { self.description.isEmpty  }
 public init(data: [Selector: Property] = .empty, css: String? = nil) {
  self.data = data
  // add custom css before generating
  self.css = css
  // generate before rendering with leaf
  self.css = self.generate()
 }

 public init(stringLiteral string: String) {
  self.init(css: string)
 }

 public init(elements: [(Selector, Property)], css: String? = nil) {
  self.init(data: Dictionary(uniqueKeysWithValues: elements), css: css)
 }

 public init(dictionaryLiteral elements: (Selector, Property)...) {
  self.init(elements: elements)
 }

 public init(arrayLiteral elements: (Selector, Property)...) {
  self.init(elements: elements)
 }

 public indirect enum Property:
  OptionalStringConvertible,
  ExpressibleByStringLiteral,
  ExpressibleByArrayLiteral {
  public init(stringLiteral string: String) {
   self = .string(string)
  }

  public init(arrayLiteral elements: Self...) {
   self = .variadic(elements)
  }

  // public enum Position { case center, right, left, up, down }
  public enum Color: StyleProperty, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {
   public init(stringLiteral string: String) { self = .string(string) }
   public init(integerLiteral value: Int) { self = .hex(value) }

   case string(String), hex(Int), name(Name), rgba(Int, Int, Int, Double)
   public static var clear: Self {
    rgba(0, 0, 0, 0)
   }

   public var rawValue: String {
    let string: String? = {
     switch self {
     case let .string(string): return string
     case let .hex(hex): return hex.description
     case let .name(name): return name.description
     case let .rgba(r, g, b, a):
      return "rgba(\(r), \(g), \(b), \(a))"
     }
    }()
    return string.unwrapped
   }

   public enum Name: String, StyleProperty {
    public static var name: String { Color.name }
    case clear, black, white, red, green, blue, gray
   }
  }

  public enum Background: StyleProperty {
   case color(Color)
   public var name: String {
    switch self {
    case .color: return "background-color"
    }
   }

   public var rawValue: String {
    switch self {
    case let .color(value): return value.rawValue
    }
   }
  }

  public enum Display: String, StyleProperty { case none, visible, flex }
  public enum Margin: StyleProperty, ExpressibleByIntegerLiteral {
   case auto, integer(Int)
   public init(integerLiteral value: Int) { self = .integer(value) }
   public var rawValue: String {
    switch self {
    case let .integer(value): return value.description
    case .auto: return "auto"
    }
   }
  }

  public enum JustifyContent: String, StyleProperty {
   case center, spaceAround = "space-around"
  }

  public enum AlignItems: String, StyleProperty {
   case center, top, bottom, left, right
  }

  public enum Width:
  StyleProperty, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
   case auto, max, value(Double), percent(Int)
   public init(integerLiteral value: Int) { self = .percent(value) }
   public init(floatLiteral value: Double) { self = .value(value) }

   public var rawValue: String {
    switch self {
    case let .value(double): return double.description + "px"
    case .auto: return "auto"
    case .max: return "100%"
    case let .percent(value): return "\(value)%"
    }
   }
  }

  public enum Height:
  StyleProperty, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
   case auto, max, value(Double), percent(Int)
   public init(integerLiteral value: Int) { self = .percent(value) }
   public init(floatLiteral value: Double) { self = .value(value) }

   public var rawValue: String {
    switch self {
    case let .value(double): return double.description + "px"
    case .auto: return "auto"
    case .max: return "100%"
    case let .percent(value): return "\(value)%"
    }
   }
  }

  case
   string(String), variadic([Self]), display(Display), margin(Margin),
   justify(JustifyContent), alignItems(AlignItems), color(Color), colorName(Color.Name), width(Width), height(Height),
   background(Background)

  public var description: String? {
   let string: String? = {
    switch self {
    case let .string(string):
     guard string.notEmpty else { return nil }
     return "\(string);"
    case let .display(display): return display.description
    case let .margin(margin): return margin.description
    case let .justify(justify): return justify.description
    case let .alignItems(alignment): return alignment.description
    case let .color(color): return color.description
    case let .colorName(color): return color.description
    case let .width(value): return value.description
    case let .height(value): return value.description
    case let .background(value): return value.description
    case let .variadic(elements):
     return elements.compactMap(\.description)
      .wrapped?.map { " \($0)" }.unique().joined(separator: "\n")
    }
   }()
   return string
  }

  @resultBuilder
  public enum Builder {
   public static func buildBlock(component: Property) -> Property {
    component
   }
   public static func buildBlock(_ components: Property...) -> Property {
    .variadic(components)
   }
  }

  public static func > (self: Self, other: Self) -> Self {
   switch self {
   case let .variadic(elements):
    return .variadic(elements + [other])
   default: return [self, other]
   }
  }
 }

 public indirect enum Selector:
 Hashable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
  case string(String), variadic([Self])
  public init(stringLiteral string: String) {
   self = .string(string)
  }

  public init(arrayLiteral elements: Self...) {
   self = .variadic(elements)
  }

  public var string: String? {
   switch self {
   case let .string(string): return string.isEmpty ? nil : string
   case let .variadic(elements):
    return
     elements.compactMap(\.string).wrapped?.unique().joined(separator: ", ")
   }
  }
 }

 /// A selector and property store
 public var data: [Selector: Property] = .empty
 /// A complete css closure
 public var css: String?

 public func generate() -> String? {
  // if there are no properties return nil but render if there are properties
  self.data.wrapped?.compactMap { key, value in
   guard let sel = key.string,
         let prop = value.description else { return nil }
   return "\(sel) {\n\(prop)\n}"
  }.wrapped?.joined(separator: "\n").appending(
   "\(self.css.unwrap { "\n\($0)" })"
  ) ?? self.css
 }

 public var description: String { self.css ?? "No content" }

 public init(css: String? = nil, _ pairs: (Selector, Property)...) {
  self.init(elements: pairs, css: css)
 }

 public init(_ selector: Selector, properties: () -> Property) {
  self.init(elements: [(selector, properties())])
 }
}

// MARK: Static properities
infix operator >: AdditionPrecedence
public extension Style.Selector {
 static var html: Self { "html" }
 static var body: Self { "body" }
 static var title: Self { "title" }
 static var h1: Self { "h1" }
 static var h2: Self { "h2" }
 static var h3: Self { "h3" }
 static var button: Self { "button" }
 static var span: Self { "span" }
 static var ul: Self { "ul" }
 static var li: Self { "li" }
}

public extension Style.Property {
 // margin: auto;
 // display: flex;
 // justify-content: center;
 // align-items: center;
 static var center: Self {
  .margin(.auto) > .display(.flex) > .justify(.center) > .alignItems(.center)
 }
}

public extension Style {
 static func center(_ selector: Selector...) -> Self {
  Self(data: [.variadic(selector): .center])
 }
}

public extension KeyValuePairs where Key == String, Value == Style {
 static var centerBody: Self { ["centerBody": .center(.body)] }
}

#if canImport(Leaf) && canImport(LeafKit)
 import Leaf
 import LeafKit
 /// the style must contain css that's loaded from this tag as
 /// `app.leaf.tags = ["string"] = StyleTag()
 /// in the leaf file it should look like
 /// `#string("public variablename", "otherpublic variablename")`
 public struct StyleTag: LeafTag, CustomStringConvertible {
  public static var cache: [String: Style] = .empty
  public var description: String {
   "\(Self.cache.map { "\"\($0)\" ⏎\n\n\($1)" }.joined(separator: ",\n\n"))"
  }

  public init(entries: [KeyValuePairs<String, Style>]) {
   precondition(
    Self.cache.isEmpty && entries.notEmpty,
    "Styles can't be empty and must be publicitalized once to save time"
   )
   for entry in entries {
    for (name, style) in entry { Self.cache[name] = style }
   }
  }

  /** - Remark storing with key value pairs for now because of the syntax
   public public var key: String = .empty
   public var value: Style = .empty
   */
  public enum Error: LocalizedError {
   case
    noParameters, invalidParameter(LeafData),
    invalidKey(String, LeafData), noContent(String)
   public var errorDescription: String? {
    switch self {
    case .noParameters:
     return "No parameters string literals were entered into \"#style()\""
    case let .invalidParameter(data):
     return "Invalid parameter \(data) was entered into \"#style()\""
    case let .invalidKey(key, data):
     return "Invalid key \"\(key)\" was entered into \"#style(\(data)\""
    case let .noContent(name):
     return "No css content was generated for style \"\(name)\""
    }
   }
  }

  public func render(_ ctx: LeafContext) throws -> LeafData {
   .string(
    try ctx.parameters.wrapped.throwing(Error.noParameters).compactMap {
     /// - Note: `LeafData` can be coerced to string or array to nest the data
     /// but rendering is done beforehand each time and selector/property sets are discared
     let key = try $0.string.throwing(Error.invalidParameter($0))
     let style = try Self.cache[key].throwing(Error.invalidKey(key, $0))
     return try style.css.throwing(Error.noContent(key)).appending(";")
    }.joined(separator: "\n")
   )
  }
 }
#endif

extension String: Infallible {
 public static let defaultValue: Self = .empty
}
