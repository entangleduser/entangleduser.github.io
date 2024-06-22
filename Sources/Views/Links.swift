#if os(WASI)
import struct Core.InterfaceID
import class JavaScriptKit.JSObject

/// A link that moves window history state based on interface id.
///
/// Useful for routing links within an app, instead of opening a new one.
///
/// - parameters:
///  - id: The interface id for the link, which is converted to a path.
///  - interface: The current interface binding.
///  - content: The view content for the link.
public struct RouteLink<Content: View>: View {
 let id: InterfaceID
 @Binding
 var interface: InterfaceID
 @ViewBuilder
 var content: () -> Content

 public init(
  id: InterfaceID,
  interface: Binding<InterfaceID>,
  @ViewBuilder content: @escaping () -> Content
 ) {
  self.id = id
  _interface = interface
  self.content = content
 }

 public var body: some View {
  let ignore = interface == id
  DynamicHTMLView(
   ignore ? "div" : "a href",
   ["style": "text-decoration: none;"],
   listeners: [
    "click": { event in
     event.preventDefault?().function?.callAsFunction()
     guard !ignore else { return }
     
     let window = JSObject.global.window
     
     // push back if there are additional paths
     if interface.primary != nil {
      window.history.pushState(
       window.undefined, "", "/"
      ).function?
       .callAsFunction()
     }
     window.history.pushState(
      window.undefined, "", id.path
     ).function?
      .callAsFunction()
     interface = id
    }
   ]
  ) {
   content()
  }
 }
}
#endif
