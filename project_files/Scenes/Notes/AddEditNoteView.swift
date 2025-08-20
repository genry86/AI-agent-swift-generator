import SwiftUI

/// Sheet view for adding or editing a note.
struct AddEditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isPinned: Bool = false
    @State private var errorMessage: String?

    var note: Note?
    var onSave: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            TextField("Title (optional)", text: $title)
            TextEditor(text: $content)
                .frame(minHeight: 200)
                .border(Color.gray.opacity(0.2))
            Toggle("Pin note", isOn: $isPinned)
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                if note != nil {
                    Button("Delete") { delete() }
                }
                Button("Save") { save() }
                    .disabled(content.isEmpty)
            }
        }
        .padding()
        .onAppear {
            if let n = note {
                title = n.title ?? ""
                content = n.content
                isPinned = n.isPinned
            }
        }
    }

    private func save() {
        guard let url = (NotificationCenter.default.userInfo?["currentURL"] as? URL) else {
            errorMessage = "No page URL available."
            return
        }
        let service = NoteService()
        if let n = note {
            service.update(n, title: title.isEmpty ? nil : title, content: content, isPinned: isPinned)
        } else {
            service.add(title: title.isEmpty ? nil : title, content: content, url: url, isPinned: isPinned)
        }
        onSave?()
        dismiss()
    }

    private func delete() {
        if let n = note {
            NoteService().delete(n)
            onSave?()
            dismiss()
        }
    }
}