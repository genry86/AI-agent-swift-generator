import SwiftUI

/// Reusable toolbar button with SF Symbol.
struct ToolbarButtonView: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}