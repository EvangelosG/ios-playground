import SwiftUI

struct RootTabView: View {
    @State private var selection: String = DemoCatalog.tabs[0].id

    var body: some View {
        TabView(selection: $selection) {
            ForEach(DemoCatalog.tabs) { tab in
                Tab(tab.title, systemImage: tab.symbol, value: tab.id) {
                    DemoTabView(tab: tab)
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

/// One tab: a navigation stack over the tab's catalog, with search across the
/// whole app and a `DemoID`-driven destination.
struct DemoTabView: View {
    let tab: DemoTab

    @State private var path: [DemoID] = []
    @State private var query: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if query.isEmpty {
                    Section {
                        Text(tab.blurb)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(tab.sections) { section in
                        Section(section.title) {
                            ForEach(section.demos) { demo in
                                DemoRow(demo: demo)
                            }
                        }
                    }
                } else {
                    Section("Results") {
                        ForEach(DemoCatalog.search(query)) { demo in
                            DemoRow(demo: demo)
                        }
                    }
                }
            }
            .navigationTitle(tab.title)
            .searchable(text: $query, prompt: "Search all demos")
            .navigationDestination(for: DemoID.self) { id in
                if let demo = DemoCatalog.demo(id: id) {
                    DemoScreen(demo: demo)
                } else {
                    ContentUnavailableView("Unknown demo", systemImage: "questionmark.circle")
                }
            }
        }
    }
}

struct DemoRow: View {
    let demo: Demo

    var body: some View {
        NavigationLink(value: demo.id) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(demo.title)
                    Text(demo.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: demo.symbol)
                    .foregroundStyle(.tint)
            }
        }
        .accessibilityIdentifier("demo.\(demo.id.rawValue)")
    }
}

#Preview {
    RootTabView()
}
