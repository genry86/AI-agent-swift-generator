import SwiftUI

/// Preferences window content.
struct SettingsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var homepage: String = Constants.defaultHomepage.absoluteString

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General")
                .font(.title2)
            HStack {
                Text("Default homepage:")
                TextField("URL", text: $homepage)
                    .textFieldStyle(.roundedBorder)
            }
            Button("Save") {
                if let url = URL(string: homepage), url.isValid {
                    // Save to settings storage if needed.
                }
            }
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}