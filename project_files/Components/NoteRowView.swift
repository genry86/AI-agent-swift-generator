import SwiftUI

/// Row view for a single note.
struct NoteRowView: View {
    let note: Note

    var body: some View {
        HStack {
            if let imageData = note.value(forKey: "imageData") as? Data,
               let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(systemName: "note.text")
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(note.title ?? "Untitled")
                    .font(.system(.body, design: .default))
                Text(note.content.prefix(50) + "...")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if note.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }
}