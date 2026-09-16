import SwiftUI

/// A self-contained navigation sandbox: a typed path you can inspect, push to,
/// and unwind — the pattern real apps use for deep links and state restoration.
/// It runs in a sheet so its stack stays separate from the catalog's own.
struct NavigationDemo: View {
    enum Route: Hashable {
        case album(String)
        case track(String)
        case settings
    }

    @State private var showingMiniApp = false

    var body: some View {
        DemoCard("A stack of its own", caption: "Opens a miniature music app driven by a typed [Route] path.") {
            Button("Open the mini app", systemImage: "rectangle.stack") {
                showingMiniApp = true
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("openMiniApp")
        }
        .sheet(isPresented: $showingMiniApp) {
            MiniApp()
        }

        TryItNote("Push a few screens, then use the deep-link button to jump two levels at once.")
    }
}

private struct MiniApp: View {
    @Environment(\.dismiss) private var dismiss
    @State private var path: [NavigationDemo.Route] = []

    private let albums = ["Kind of Blue", "Blue Train", "Moon Safari"]

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Albums") {
                    ForEach(albums, id: \.self) { album in
                        NavigationLink(album, value: NavigationDemo.Route.album(album))
                    }
                }
                Section("The path") {
                    Text(path.isEmpty ? "empty" : String(describing: path))
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                    Button("Deep link: album → track") {
                        path = [.album("Blue Train"), .track("Moment's Notice")]
                    }
                    Button("Pop to root") { path.removeAll() }
                        .disabled(path.isEmpty)
                }
            }
            .navigationTitle("Library")
            .navigationDestination(for: NavigationDemo.Route.self) { route in
                destination(for: route)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: NavigationDemo.Route) -> some View {
        switch route {
        case .album(let name):
            List {
                Section("Tracks") {
                    ForEach(["Opening", "Moment's Notice", "Closing"], id: \.self) { track in
                        NavigationLink(track, value: NavigationDemo.Route.track(track))
                    }
                }
                Button("Push settings") { path.append(.settings) }
            }
            .navigationTitle(name)
        case .track(let name):
            VStack(spacing: 12) {
                Image(systemName: "music.note")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)
                Text(name).font(.title2)
                Button("Back to root") { path.removeAll() }
                    .buttonStyle(.borderedProminent)
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
        case .settings:
            Form {
                Toggle("Downloads over cellular", isOn: .constant(false))
                Toggle("Lossless audio", isOn: .constant(true))
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    NavigationDemo()
}
