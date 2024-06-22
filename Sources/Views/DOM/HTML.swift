#if !canImport(SwiftUI)
import Core
import JavaScriptKit
import protocol TokamakCore.View
@_exported import struct TokamakStaticHTML.HTMLAttribute

import struct TokamakCore.Environment
import protocol TokamakCore.EnvironmentKey
import struct TokamakCore.EmptyView


public struct EnvironmentTag: EnvironmentKey {
 public static let defaultValue: String = .empty
 public init() {}
}

public extension EnvironmentValues {
 var tag: String {
  get { self[EnvironmentTag.self] }
  set { self[EnvironmentTag.self] = newValue }
 }
}

public struct EnvironmentAttributres: EnvironmentKey {
 public static let defaultValue: [HTMLAttribute: String] = .empty
 public init() {}
}

public extension EnvironmentValues {
 var attributes: [HTMLAttribute: String] {
  get { self[EnvironmentAttributres.self] }
  set { self[EnvironmentAttributres.self] = newValue }
 }
}

public extension HTMLView {
 func htmlAttributes(
  _ attributes: [HTMLAttribute: String]
 ) -> Self {
  Self(
   tag: self.tag,
   attributes: attributes.resolvedAttributes(attributes),
   content: content
  )
 }

 func htmlTag(_ tag: String) -> Self {
  Self(
   tag: self.resolvedTag(tag),
   attributes: self.attributes,
   content: content
  )
 }

 func tagWithAttributes(
  _ tag: String, _ attributes: [HTMLAttribute: String] = .empty
 ) -> Self {
  Self(
   tag: self.resolvedTag(tag),
   attributes: attributes.resolvedAttributes(attributes),
   content: content
  )
 }
}

/// An HTML view that stores and asseses environment variables, listeners, and
/// attributes.
public struct DynamicHTMLView<Content>: View {
 public func resolvedTag(_ tag: String) -> String {
  var split =
   tag.split(separator: .space, omittingEmptySubsequences: true)
  if !split.contains(where: { $0.base == tag }) {
   split.append(Substring(tag))
   return split.joined(separator: .space)
  } else {
   return self.tag + .space + tag
  }
 }

 public let tag: String
 public let attributes: [HTMLAttribute: String]
 public let listeners: [String: Listener]
 public let content: DynamicHTML<Content>

 @Environment(\.self)
 var environment
 public var body: some View {
  content
   .environment(\.tag, resolvedTag(environment.tag))
   .environment(
    \.attributes, attributes.resolvedAttributes(environment.attributes)
   )
 }
}

public extension DynamicHTMLView {
 init(
  _ tag: String,
  _ attributes: [HTMLAttribute: String] = .empty,
  listeners: [String: Listener] = .empty,
  @ViewBuilder content: @escaping () -> Content
 ) where Content: View {
  self.tag = tag
  self.attributes = attributes
  self.listeners = listeners
  self.content = DynamicHTML(
   tag, attributes, listeners: listeners, content: content
  )
 }

 init(
  _ tag: String,
  _ attributes: [HTMLAttribute: String] = .empty,
  listeners: [String: Listener] = .empty,
  content: Content
 ) where Content: StringProtocol {
  self.tag = tag
  self.attributes = attributes
  self.listeners = listeners
  self.content = DynamicHTML(
   tag, attributes, listeners: listeners, content: content
  )
 }

 init(
  _ tag: String,
  _ attributes: [HTMLAttribute: String] = .empty,
  listeners: [String: Listener] = .empty,
  content: Content
 ) where Content: View {
  self.init(
   tag,
   attributes,
   listeners: listeners,
   content: { content }
  )
 }
}

extension DynamicHTMLView where Content == EmptyView {
 init(_ tag: String, _ attributes: [HTMLAttribute: String] = .empty) {
  self.init(tag, attributes, content: EmptyView.init)
 }
}

/// An HTML view that stores and asseses environment variables and attributes.
public struct HTMLView<Content>: View {
 public func resolvedTag(_ tag: String) -> String {
  var split =
   tag.split(separator: .space, omittingEmptySubsequences: true)
  if !split.contains(where: { $0.base == tag }) {
   split.append(Substring(tag))
   return split.joined(separator: .space)
  } else {
   return self.tag + .space + tag
  }
 }

 public let tag: String
 public let attributes: [HTMLAttribute: String]
 public let content: HTML<Content>

 @Environment(\.self)
 var environment
 public var body: some View {
  content
   .environment(\.tag, resolvedTag(environment.tag))
   .environment(
    \.attributes, attributes.resolvedAttributes(environment.attributes)
   )
 }
}

public extension HTMLView {
 init(
  _ tag: String,
  _ attributes: [HTMLAttribute: String] = .empty,
  @ViewBuilder content: @escaping () -> Content
 ) where Content: View {
  self.tag = tag
  self.attributes = attributes
  self.content = HTML(tag, attributes, content: content)
 }
 
 init(
  _ tag: String,
  _ attributes: [HTMLAttribute: String] = .empty,
  content: Content
 ) where Content: StringProtocol {
  self.tag = tag
  self.attributes = attributes
  self.content = HTML(tag, attributes, content: content)
 }

 init(
  _ tag: String,
  _ attributes: [HTMLAttribute: String] = .empty,
  content: Content
 ) where Content: View {
  self.init(
   tag,
   attributes,
   content: { content }
  )
 }
}

extension HTMLView where Content == EmptyView {
 init(_ tag: String, _ attributes: [HTMLAttribute: String] = .empty) {
  self.init(tag, attributes, content: EmptyView.init)
 }
}

public extension HTMLAttribute {
 static var placeholder: Self { "placeholder" }
 static var maxLength: Self { "maxlength" }
 static var height: Self { "height" }
 static var width: Self { "width" }
 static var style: Self { "style" }
 static var id: Self { "id" }
 static var `class`: Self { "class" }
 static var type: Self { "type" }
 static var script: Self { "script" }
 static var onLoad: Self { "onload" }
 static var onClick: Self { "onclick" }
}

import Styles

public extension [HTMLAttribute: String] {
 static func style(_ property: Style.Property) -> Self {
  [.style: property.description!]
 }

 func resolvedAttributes(_ other: Self) -> Self {
  var newAttributes = self
  for (key, value) in other {
   // create a split of each attribute of a key
   if
    let oldSplit = self[key]?
     .split(separator: ";", omittingEmptySubsequences: true).wrapped {
    // unique old values to create one string of properties
    // split and append only if the are duplicates
    let newSplit =
     value.split(separator: ";", omittingEmptySubsequences: true)

    // nothing to resolve if there aren't any valid properties
    if
     let keyValues: [(Substring, Substring)] =
     newSplit.compactMap({ property in
      let proposedSplit =
       property.split(separator: ":", omittingEmptySubsequences: true)
      guard proposedSplit.count == 2 else { return nil }

      return (proposedSplit[0], proposedSplit[1])
     }).wrapped,
     let oldKeyValues: [(Substring, Substring)] =
     oldSplit.compactMap({ property in
      let proposedSplit =
       property.split(separator: ":", omittingEmptySubsequences: true)
      guard proposedSplit.count == 2 else { return nil }

      return (proposedSplit[0], proposedSplit[1])
     }).wrapped {
     var dictionary: [String: String] = .empty

     for (key, value) in oldKeyValues {
      dictionary[key.base] = value.base
     }

     for (key, value) in keyValues {
      dictionary[key.base] = value.base
     }

     // update the key with a mapped version of the attributes
     newAttributes[key] = dictionary.map { "\($1)" }.joined(separator: " ")
    } else {
     newAttributes[key] = value
    }
   } else {
    // set unique if not delimited with `;`
    newAttributes.append(contentsOf: other)
   }
  }
  return newAttributes
 }
}
#endif
