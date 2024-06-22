#!/usr/bin/env swift-shell -u
import Breakfast // $main/tests/Breakfast
import Command // $main/Command
import PathObserver // @git/acrlc/paths
import Tests // $main/Acrylic

/// This is a command I use to update the syntax using a file observer.
@main
struct MarkdownRenderer: Module & AsyncCommand {
 @Input
 var input: File?

 func printComponents(from string: String) throws {
  let components = try MarkdownSyntax.renderTokens(from: string)
  print("Input:", string, separator: .newline)
  print(
   "Output:",
   components.map {
    let component = $0.component
    let debugString = $0.string.debugDescription
    return [component.description, debugString].joined(separator: ", ")
   }.joined(separator: .newline),
   separator: .newline
  )
 }

 var void: some Module {
  get throws {
   if let input {
    let string = try input.readAsString()
    Perform {
     try printComponents(from: string)
    }
   }
   else {
    exit(2, "usage: markdown.swift -i <path>")
   }
  }
 }
}

/// Markdown renderering property wrapper / module concept
@propertyWrapper
struct MarkdownSyntaxModule: AsyncFunction, ContextualProperty {
 @Context
 var wrappedValue: String

 init(input: Context<String>) {
  _wrappedValue = input
 }

 init(wrappedValue: String) {
  _wrappedValue = .constant(wrappedValue)
 }

 var projectedValue: Context<String> {
  _wrappedValue
 }

 public var id: Int {
  get { _wrappedValue.id }
  set { _wrappedValue.id = newValue }
 }

 public var context: ModuleContext {
  get { _wrappedValue.context }
  set { _wrappedValue.context = newValue }
 }

 public mutating func update() {
  _wrappedValue.update()
 }

 func callAsFunction() async throws -> [ComponentData<String>] {
  try MarkdownSyntax.renderTokens(from: wrappedValue)
 }
}

@_spi(ModuleReflection) import Acrylic
extension MarkdownRenderer {
 mutating func main() async throws {
  do { try await (void as! Modules).callAsFunction() }
  catch {
   throw error
  }
 }
}
