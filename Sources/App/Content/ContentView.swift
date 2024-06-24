import Core
import Views

struct ContentView: View {
 let blog = Blog.shared

 var githubLink: some View {
  Link("Github", destination: .github)
   .foregroundStyle(.secondary)
   .font(.body)
 }

 #if os(WASI)
 func toolbar() -> some View {
  HStack(spacing: 0) {
   Text(blog.title)
    .lineLimit(1)
    .font(.mediumHeader)
    .padding(.vertical, 11.5)
    .opacity(0.77)
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
  HomeView()
   .toolbar(content: toolbar)
 }

 var body: some View {
  #if os(WASI)
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
