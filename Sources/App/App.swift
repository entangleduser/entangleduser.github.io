import Views

struct BlogApp: App {
 let blog = Blog.shared

 var body: some Scene {
  WindowGroup(blog.name) {
   ContentView()
  }
 }
}

@main
struct LoadApp {
 static func main() {
  Blog.shared.load()
  Task { @MainActor in
   await Resources.Text.shared.load()
   BlogApp.main()
  }
 }
}
