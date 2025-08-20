import Foundation
import CoreData

/// Service handling CRUD operations for notes.
class NoteService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    /// Fetches notes for a given page URL.
    func fetchNotes(for url: URL) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "urlString == %@", url.absoluteString)
        request.sortDescriptors = [NSSortDescriptor(keyPath: "order", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    /// Adds a new note.
    func add(title: String?, content: String, url: URL, isPinned: Bool = false) {
        let note = Note(context: context)
        note.id = UUID()
        note.title = title
        note.content = content
        note.urlString = url.absoluteString
        note.isPinned = isPinned
        note.createdAt = Date()
        note.updatedAt = Date()
        note.order = Int64(Date().timeIntervalSince1970)
        saveContext()
    }

    /// Updates an existing note.
    func update(_ note: Note, title: String?, content: String, isPinned: Bool) {
        note.title = title
        note.content = content
        note.isPinned = isPinned
        note.updatedAt = Date()
        saveContext()
    }

    /// Deletes a note.
    func delete(_ note: Note) {
        context.delete(note)
        saveContext()
    }

    /// Persists changes.
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}