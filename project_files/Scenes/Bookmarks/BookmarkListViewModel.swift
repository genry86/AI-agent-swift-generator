import SwiftUI
import Combine

/// ViewModel for BookmarkListView handling state and actions.
class BookmarkListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var bookmarks: [Bookmark] = []
    @Published var editingBookmark: Bookmark?
    @Published var showDeleteAlert = false
    private var bookmarkToDelete: Bookmark?

    private var cancellables = Set<AnyCancellable>()
    private let service = BookmarkService()

    init() {
        fetchBookmarks()
        setupSearch()
    }

    /// Fetches bookmarks from service.
    func fetchBookmarks() {
        bookmarks = service.fetchAll()
    }

    /// Refreshes list after changes.
    func refresh() {
        fetchBookmarks()
    }

    /// Computed filtered list based on search text.
    var filteredBookmarks: [Bookmark] {
        guard !searchText.isEmpty else { return bookmarks }
        return bookmarks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.urlString.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Handles selection to load in web view.
    func select(_ bookmark: Bookmark) {
        if let url = bookmark.url {
            NotificationCenter.default.post(name: .didSelectURL, object: url)
        }
    }

    /// Starts editing a bookmark.
    func edit(_ bookmark: Bookmark) {
        editingBookmark = bookmark
    }

    /// Adds a new bookmark (opens sheet with empty bookmark).
    func addBookmark() {
        editingBookmark = nil // Sheet will treat nil as new.
    }

    /// Adds a new folder (not implemented).
    func addFolder() {
        // Placeholder for folder creation.
    }

    /// Imports bookmarks (placeholder).
    func importBookmarks() {
        // Implement file picker and import logic.
    }

    /// Exports bookmarks (placeholder).
    func exportBookmarks() {
        // Implement export logic.
    }

    /// Initiates delete confirmation.
    func confirmDelete(_ bookmark: Bookmark) {
        bookmarkToDelete = bookmark
        showDeleteAlert = true
    }

    /// Performs deletion after confirmation.
    func deleteConfirmed() {
        if let bookmark = bookmarkToDelete {
            service.delete(bookmark)
            fetchBookmarks()
        }
        showDeleteAlert = false
        bookmarkToDelete = nil
    }

    /// Delete via swipe or edit actions.
    func delete(at offsets: IndexSet) {
        offsets.map { bookmarks[$0] }.forEach { service.delete($0) }
        fetchBookmarks()
    }

    /// Move bookmarks.
    func move(from source: IndexSet, to destination: Int) {
        var reordered = bookmarks
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, bookmark) in reordered.enumerated() {
            bookmark.order = Int64(index)
        }
        service.saveContext()
        fetchBookmarks()
    }

    /// Sets up Combine pipeline for search.
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}