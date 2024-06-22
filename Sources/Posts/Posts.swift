import Extensions
import struct Foundation.URL

public extension URL {
 static let posts: Self = "posts"
}

#if os(WASI)
// MARK: Generated Content
import Foundation
extension Post: CaseIterable {
 public static var allCases: Posts = [
  Post(
   id: "2024-01-01-Headline",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline2",
   headline: "Headline",
   subheadline: "Subheadline"
  ),
  Post(
   id: "2024-01-01-Headline3",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline4",
   headline: "Headline",
   subheadline: "Subheadline"
  ), Post(
   id: "2024-01-01-Headline5",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline6",
   headline: "Headline",
   subheadline: "Subheadline"
  ),
  Post(
   id: "2024-01-01-Headline7",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline8",
   headline: "Headline",
   subheadline: "Subheadline"
  ),
  Post(
   id: "2024-01-01-Headline9",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline10",
   headline: "Headline",
   subheadline: "Subheadline"
  ), Post(
   id: "2024-01-01-Headline11",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline12",
   headline: "Headline",
   subheadline: "Subheadline"
  ), Post(
   id: "2024-01-01-Headline13",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline14",
   headline: "Headline",
   subheadline: "Subheadline"
  ),
  Post(
   id: "2024-01-01-Headline15",
   headline: "Headline",
   subheadline: "An introduction"
  ),
  Post(
   id: "2024-01-01-Headline16",
   headline: "Headline",
   subheadline: "Subheadline"
  )
 ]
}
#else
extension Post: CaseIterable {
 public static var allCases: Posts = .empty
}
#endif
