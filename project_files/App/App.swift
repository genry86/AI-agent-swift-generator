import SwiftUI

/// Entry point of the macOS browser app.
@main
struct BrowserApp: App {
    // Inject environment with services.
    @StateObject private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(appEnvironment)
        }
        .commands {
            SettingsCommands()
        }
    }
}