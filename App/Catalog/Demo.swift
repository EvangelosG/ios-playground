import SwiftUI

/// Stable identifier for a demo, used as the value pushed onto a `NavigationStack`
/// and as the accessibility identifier that UI tests navigate by.
struct DemoID: Hashable, Codable, RawRepresentable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// How a demo wants to be hosted. Demos that own their own scrolling (lists,
/// scroll views, maps) are presented `.plain`; everything else is wrapped in a
/// padded `ScrollView`.
enum DemoLayout: Sendable {
    case scroll
    case plain
}

/// The explanation shown behind the "How it works" toolbar button.
struct DemoNotes: Sendable {
    let explanation: String
    let code: String
    let apis: [String]

    init(explanation: String, code: String, apis: [String] = []) {
        self.explanation = explanation
        self.code = code
        self.apis = apis
    }
}

@MainActor
struct Demo: Identifiable {
    let id: DemoID
    let title: String
    let summary: String
    let symbol: String
    let layout: DemoLayout
    let notes: DemoNotes
    let content: () -> AnyView

    init(
        id: String,
        title: String,
        summary: String,
        symbol: String,
        layout: DemoLayout = .scroll,
        notes: DemoNotes,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.id = DemoID(id)
        self.title = title
        self.summary = summary
        self.symbol = symbol
        self.layout = layout
        self.notes = notes
        self.content = { AnyView(content()) }
    }
}

@MainActor
struct DemoSection: Identifiable {
    let id: String
    let title: String
    let demos: [Demo]
}

@MainActor
struct DemoTab: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let blurb: String
    let sections: [DemoSection]

    var demos: [Demo] { sections.flatMap(\.demos) }
}
