import Acrylic
import Extensions
import Views

extension Resources {
 final class Text: ObservableModule {
  static var shared = Text()
  @Alias(Blog.self)
  var blog
  @Published
  var home: String = .empty

  var void: some Module {
   Perform.Async { @MainActor in
    do {
     #if os(WASI)
     // fetch using javascript, data support doesn't seem feasible due to there
     // not being foundation networking support
     let text = try await String(fileName: "Home.text")
     home = text
     await self.contextWillChange.send()

     #else
     let url = try Bundle.module.url(forResource: "Home", withExtension: "text")
      .throwing(
       reason: """
       The file 'Home.text' couldn't be found in resources bundle! \

       Make sure that it's processed as SPM resource or copied within your \
       bundle under the resources folder.
       """
      )

     self.home = try String(contentsOf: url, encoding: .utf8)
     #endif
    } catch {
     let message = error.message
     let delimiterIndex =
      message.index(
       after:
       message[
        message.index(
         after: message.firstIndex(of: .colon)!
        )...
       ]
       .firstIndex(of: .colon)!
      )
     blog.log(String(message[delimiterIndex...]), for: .error)
    }
   }
  }
 }
}

extension MarkdownText {
 init(id: InterfaceID, _ text: String) {
  self.init(id: id.rawValue, text)
 }
}
