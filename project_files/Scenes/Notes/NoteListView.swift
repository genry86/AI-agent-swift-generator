import SwiftUI

/// View displaying notes attached to the current webpage.
struct NoteListView: View {
    @StateObject private var viewModel = NoteListViewModel()
    @State private var showingAddNote = false

    var body: some View {
        VStack {
            // Search field
            TextField("Search notes", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            // List of notes
            List {
                ForEach(viewModel.filteredNotes) { note in
                    NoteRowView(note: note)
                        .contextMenu {
                            Button("Edit") { viewModel.edit(note) }
                            Button("Delete", role: .destructive) { viewModel.delete(note) }
                        }
                }
                .onMove(perform: viewModel.move)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing)
            {
                Button(action: { showingAddNote = true }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.secondary)
                }
                Button(action: viewModel.exportNotes) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddEditNoteView(note: nil)
        }
        .sheet(item: $viewModel.editingNote) { note in
            AddEditNoteView(note: note)
        }
    }
}