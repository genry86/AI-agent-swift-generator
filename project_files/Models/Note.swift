import Foundation
import CoreData

/// Core Data entity representing a note attached to a webpage.
@objc(Note)
public class Note: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String?
    @NSManaged public var content: String
    @NSManaged public var isPinned: Bool
    @NSManaged public var order: Int64
    @NS.NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var urlString: String
}

/// Convenience computed property.
extension Note {
    /// Returns URL of the page the note is attached to.
    var url: URL? {
        return URL(string: urlString)
    }
}