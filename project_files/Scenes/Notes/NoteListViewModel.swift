import SwiftUI
import Combine

/// ViewModel for NoteListView handling note state.
class NoteListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var notes: [Note] = []
    @Published var editingNote: Note?

    private var cancellables = Set<AnyCancellable>()
    private let service = NoteService()
    private var currentURL: URL?

    init() {
        // Listen for URL changes.
        NotificationCenter.default.publisher(for: .didSelectURL)
            .compactMap { $0.object as? URL }
            .sink { [weak self] url in
                self?.currentURL = url
                self?.fetchNotes()
            }
            .store(in: &cancellables)
        setupSearch()
    }

    /// Fetches notes for current URL.
    func fetchNotes() {
        guard let url = currentURL else { notes = []; return }
        notes = service.fetchNotes(for: url)
    }

    /// Refresh after add/edit.
    func refresh() { fetchNotes() }

    /// Filtered notes based on search.
    var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter {
            ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Starts editing a note.
    func edit(_ note: Note) { editingNote = note }

    /// Deletes a note with undo support (simplified).
    func delete(_ note: Note) { service.delete(note); fetchNotes() }

    /// Moves notes order.
    func move(from source: IndexSet, to destination: Int) {
        var reordered = notes
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, note) in reordered.enumerated() {
            note.order = Int64(index)
        }
        service.saveContext()
        fetchNotes()
    }

    /// Export notes (placeholder).
    func exportNotes() { }

    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
}