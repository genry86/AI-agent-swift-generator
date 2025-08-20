import CoreData

/// Core Data stack singleton.
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "BrowserModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved Core Data error \(error)")
            }
        }
    }
}