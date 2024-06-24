import Foundation
import Views

struct HomeView: View {
 var body: some View {
  VStack(alignment: .leading) {
   MarkdownText(id: .home, Resources.Text.shared.home)
    .font(.body)
    .opacity(0.77)
    .padding(.horizontal)
  }
  .frame(minWidth: 333, alignment: .topLeading)
 }
}

extension InterfaceID {
 static let home: Self = "home"
}
