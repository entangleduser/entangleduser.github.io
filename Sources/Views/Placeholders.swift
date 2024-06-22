#if canImport(SwiftUI)
import Core

public struct PlaceholderText: View {
 let text: String
 let font: Font
 let scale: Text.Scale
 let size: DynamicTypeSize
 public init(
  _ text: String,
  font: Font = .largeTitle,
  size: DynamicTypeSize = .large,
  scale: Text.Scale = .default
 ) {
  self.text = text
  self.font = font
  self.size = size
  self.scale = scale
 }

 public init(
  _ convertible: some CustomStringConvertible,
  font: Font = .largeTitle,
  size: DynamicTypeSize = .large,
  scale: Text.Scale = .default
 ) {
  text = convertible.description
  self.font = font
  self.size = size
  self.scale = scale
 }

 public var body: some View {
  Text(text).font(font)
   //.dynamicTypeSize((size.previous ?? size) ..< size)
  #if os(iOS)
   .fontWeight(.bold)
  #endif
   .fontDesign(.rounded)
   .foregroundStyle(.tertiary)
   .textScale(scale)
   .lineLimit(1)
   .minimumScaleFactor(0.88)
   .frame(maxWidth: .infinity, maxHeight: .infinity)
   .padding(8.5)
 }
}

public extension View {
 @ViewBuilder
 func placeholder(_ content: some View, when show: Bool) -> some View {
  if show {
   content
  } else {
   self
  }
 }

 @ViewBuilder
 func placeholder(
  text: String,
  font: Font = .largeTitle,
  size: DynamicTypeSize = .large,
  scale: Text.Scale = .default,
  when show: Bool
 ) -> some View {
  if show {
   PlaceholderText(text, size: size, scale: scale)
  } else {
   self
  }
 }

 @ViewBuilder
 func placeholder(
  _ value: some CustomStringConvertible,
  font: Font = .largeTitle,
  size: DynamicTypeSize = .large,
  scale: Text.Scale = .default,
  when show: Bool
 ) -> some View {
  if show {
   PlaceholderText(value, size: size, scale: scale)
  } else {
   self
  }
 }
}
#else
extension Text {
 public struct Scale: Sendable, Hashable {
  let rawValue: Double
  
  init(rawValue: Double) {
   self.rawValue = rawValue
  }
  /// Defines default text scale
  ///
  /// When specified uses the default text scale.
  public static let `default` = Text.Scale(rawValue: 1)
  
  /// Defines secondary text scale
  ///
  /// When specified a uses a secondary text scale.
  public static let secondary = Text.Scale(rawValue: 0.77)
 }
}

public struct PlaceholderText: View {
 let text: String
 let font: Font
 let scale: Text.Scale
 public init(
  _ text: String,
  font: Font = .largeTitle,
  scale: Text.Scale = .default
 ) {
  self.text = text
  self.font = font
  self.scale = scale
 }

 public init(
  _ convertible: some CustomStringConvertible,
  font: Font = .largeTitle,
  scale: Text.Scale = .default
 ) {
  text = convertible.description
  self.font = font
  self.scale = scale
 }

 public var body: some View {
  let textContent =
  Text(text)
   .font(font)

  Group {
   if scale == .default {
    textContent
   } else {
    textContent.scaleEffect(scale.rawValue)
   }
  }
   .foregroundStyle(.tertiary)
   //.lineLimit(1)
   //.minimumScaleFactor(0.88)
   .frame(maxWidth: .infinity, maxHeight: .infinity)
   .padding(8.5)
 }
}

public extension View {
 @ViewBuilder
 func placeholder(_ content: some View, when show: Bool) -> some View {
  if show {
   content
  } else {
   self
  }
 }

 @ViewBuilder
 func placeholder(
  text: String,
  font: Font = .largeTitle,
  scale: Text.Scale = .default,
  when show: Bool
 ) -> some View {
  if show {
   PlaceholderText(text, scale: scale)
  } else {
   self
  }
 }

 @ViewBuilder
 func placeholder(
  _ value: some CustomStringConvertible,
  font: Font = .largeTitle,
  scale: Text.Scale = .default,
  when show: Bool
 ) -> some View {
  if show {
   PlaceholderText(value, scale: scale)
  } else {
   self
  }
 }
}
#endif
