import SwiftUI

/// Holds shared services and global UI state.
class AppEnvironment: ObservableObject {
    // MARK: Services
    let bookmarkService = BookmarkService()
    let noteService = NoteService()
    let webService = WebNavigationService()

    // MARK: UI state
    @Published var showSettings = false
}