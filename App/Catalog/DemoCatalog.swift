import SwiftUI

/// The single source of truth for everything the app can show. Adding a demo
/// anywhere in here makes it appear in its tab, reachable by `DemoID`, and
/// covered by the UI test that walks the whole catalog.
@MainActor
enum DemoCatalog {
    static let tabs: [DemoTab] = [
        FoundationsTab.tab,
        DataTab.tab,
        MotionTab.tab,
        PlatformTab.tab,
        InteropTab.tab
    ]

    static var allDemos: [Demo] { tabs.flatMap(\.demos) }

    static func demo(id: DemoID) -> Demo? {
        allDemos.first { $0.id == id }
    }

    static func search(_ query: String) -> [Demo] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return allDemos.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
                || $0.summary.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
