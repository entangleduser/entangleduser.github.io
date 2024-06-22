import Acrylic
import Foundation
import Views

struct HomeView: View {
 @ObservedAlias(\Resources.Text.home, true)
 var text

 var body: some View {
  VStack(alignment: .leading) {
   MarkdownText(id: .home, text)
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
