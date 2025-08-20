import SwiftUI

/// Main window containing split view with sidebars and web content.
struct MainWindow: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationSplitView {
            // Left sidebar: bookmarks
            BookmarkListView()
        } column: {
            // Central pane: web browser
            WebBrowserView()
        } detail: {
            // Right sidebar: notes
            NoteListView()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                SidebarToggleView()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ToolbarButtonView(systemName: "gearshape", action: {
                    env.showSettings = true
                })
            }
        }
        .sheet(isPresented: $env.showSettings) {
            SettingsView()
        }
    }
}