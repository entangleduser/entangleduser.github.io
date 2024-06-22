import Views

@main
struct BlogApp: App {
 @Alias(Blog.self)
 var blog: Blog

 var body: some Scene {
  WindowGroup(blog.name) {
   ContentView()
    .environmentObject(blog)
  }
 }
}
