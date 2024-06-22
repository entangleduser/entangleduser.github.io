import Core
import Foundation
import Views

struct ContentView: View {
 @EnvironmentObject
 var blog: Blog
 
 var githubLink: some View {
  Link("Github", destination: .github)
   .foregroundStyle(.secondary)
   .font(.body)
 }

 #if os(WASI)
 func toolbar() -> some View {
  HStack(spacing: 0) {
   RouteLink(id: .home, interface: $blog.interface) {
    Text(blog.title)
     .lineLimit(1)
     .font(.mediumHeader)
     .padding(.vertical, 11.5)
     .opacity(0.77)
   }
   .offset(y: -2)

   Link("Github", destination: .github)
    .font(.body)
    .foregroundStyle(.secondary)
    .padding(15)
    .opacity(0.77)
    .frame(alignment: .trailing)
  }
  .textSelection(.disabled)
 }
 #else
 @ToolbarContentBuilder
 func toolbar() -> some ToolbarContent {
  ToolbarItem(placement: .cancellationAction) { githubLink }
 }
 #endif

 var detailPlaceholder: some View {
  PlaceholderText("No Content")
 }

 @ViewBuilder
 func detail() -> some View {
  Group {
   let interface = blog.interface
   switch interface {
   case .home, .none:
    HomeView()
   default:
    #if !canImport(SwiftUI)
    ScrollView {
     VStack(alignment: .center) {
      Spacer()
      HStack(alignment: .center) {
       Spacer()
       detailPlaceholder
        .frame(alignment: .center)
       Spacer()
      }
      Spacer()
     }
     .padding()
    }
    #else
    detailPlaceholder
    #endif
   }
  }
  .toolbar(content: toolbar)
 }

 var body: some View {
  #if !canImport(SwiftUI)
  NavigationView {
   detail()
  }
  #else
  NavigationSplitView(
   sidebar: { PlaceholderText("Sidebar", scale: .secondary) },
   content: { PlaceholderText("Content", scale: .secondary) },
   detail: detail
  )
  #endif
 }
}
