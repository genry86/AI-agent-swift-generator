import Foundation
import CoreData

/// Service handling CRUD operations for bookmarks.
class BookmarkService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    /// Fetches all bookmarks sorted by order.
    func fetchAll() -> [Bookmark] {
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: "order", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    /// Saves a new bookmark.
    func add(title: String, url: URL, folder: BookmarkFolder? = nil) {
        let bookmark = Bookmark(context: context)
        bookmark.id = UUID()
        bookmark.title = title
        bookmark.urlString = url.absoluteString
        bookmark.order = Int64(Date().timeIntervalSince1970)
        bookmark.folder = folder
        saveContext()
    }

    /// Updates an existing bookmark.
    func update(_ bookmark: Bookmark, title: String, url: URL) {
        bookmark.title = title
        bookmark.urlString = url.absoluteString
        saveContext()
    }

    /// Deletes a bookmark.
    func delete(_ bookmark: Bookmark) {
        context.delete(bookmark)
        saveContext()
    }

    /// Persists changes.
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}