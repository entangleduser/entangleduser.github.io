import Core
import Extensions
import Foundation
import Render

/// A post that can be used to generate formatted content or in an editor
/// It is designed to be read as a page within a directory and able to be
/// properly initialized from a file.
public struct Post: Identifiable {
 public var id: String
 public var url: URL?

 /// The rendered contents of this post, typed from the the file and
 /// it's contents.
 public var base: RenderedString<Self> = .empty

 /// - Note: Headline is a required field which must not be empty when
 /// exporting.
 public var headline: String
 public var subheadline: String?

 /// - Note: Creation date is a required field
 public var creationDate: Date = .now
 public var modificationDate: Date?

 init(
  id: String, url: URL? = nil,
  base: RenderedString<Post> = .empty,
  headline: String, subheadline: String? = nil,
  creationDate: Date = .now, modificationDate: Date? = nil
 ) {
  self.id = id
  self.url = url
  self.base = base
  self.headline = headline
  self.subheadline = subheadline
  self.creationDate = creationDate
  self.modificationDate = modificationDate
 }
}

public typealias Posts = [Post]
