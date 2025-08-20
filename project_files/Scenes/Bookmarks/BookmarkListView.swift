import SwiftUI

/// View displaying hierarchical list of bookmarks.
struct BookmarkListView: View {
    @StateObject private var viewModel = BookmarkListViewModel()

    var body: some View {
        VStack {
            // Search field
            TextField("Search bookmarks", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            // List of bookmarks
            List {
                ForEach(viewModel.filteredBookmarks) { bookmark in
                    BookmarkRowView(bookmark: bookmark)
                        .contextMenu {
                            Button("Open") { viewModel.select(bookmark) }
                            Button("Edit") { viewModel.edit(bookmark) }
                            Button("Delete", role: .destructive) { viewModel.confirmDelete(bookmark) }
                        }
                }
                .onDelete(perform: viewModel.delete)
                .onMove(perform: viewModel.move)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: viewModel.addFolder) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundStyle(.secondary)
                }
                Button(action: viewModel.addBookmark) {
                    Image(systemName: "bookmark.badge.plus")
                        .foregroundStyle(.secondary)
                }
                Button(action: viewModel.importBookmarks) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundStyle(.secondary)
                }
                Button(action: viewModel.exportBookmarks) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(item: $viewModel.editingBookmark) { bookmark in
            AddEditBookmarkView(bookmark: bookmark) { viewModel.refresh() }
        }
        .alert(isPresented: $viewModel.showDeleteAlert) {
            Alert(title: Text("Delete Bookmark"),
                  message: Text("Are you sure you want to delete this bookmark?"),
                  primaryButton: .destructive(Text("Delete")) { viewModel.deleteConfirmed() },
                  secondaryButton: .cancel())
        }
    }
}