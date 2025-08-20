import Foundation
import CoreData

/// Core Data entity representing a bookmark.
@objc(Bookmark)
public class Bookmark: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var urlString: String
    @NSManaged public var order: Int64
    @NSManaged public var faviconData: Data?
    @NSManaged public var folder: BookmarkFolder?
}

/// Convenience computed property.
extension Bookmark {
    /// Returns URL if valid.
    var url: URL? {
        return URL(string: urlString)
    }
}