import SwiftUI

/// Row view for a single bookmark.
struct BookmarkRowView: View {
    let bookmark: Bookmark

    var body: some View {
        HStack {
            if let data = bookmark.faviconData,
               let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(bookmark.title)
                    .font(.system(.body, design: .default))
                if let url = bookmark.url {
                    Text(url.host ?? "")
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}