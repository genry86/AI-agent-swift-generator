import SwiftUI

/// Sheet view for adding or editing a bookmark.
struct AddEditBookmarkView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var urlString: String = ""
    @State private var errorMessage: String?

    var bookmark: Bookmark?
    var onSave: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            TextField("Title", text: $title)
            TextField("URL", text: $urlString)
                .textFieldStyle(.roundedBorder)
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save") { save() }
                    .disabled(title.isEmpty || URL(string: urlString) == nil)
            }
        }
        .padding()
        .onAppear {
            if let bm = bookmark {
                title = bm.title
                urlString = bm.urlString
            }
        }
    }

    private func save() {
        guard let url = URL(string: urlString), url.isValid else {
            errorMessage = "Invalid URL"
            return
n        }
        let service = BookmarkService()
        if let bm = bookmark {
            service.update(bm, title: title, url: url)
        } else {
            service.add(title: title, url: url)
        }
        onSave?()
        dismiss()
    }
}