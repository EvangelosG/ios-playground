import SwiftUI

@MainActor
enum DataTab {
    static let tab = DemoTab(
        id: "data",
        title: "Data",
        symbol: "cylinder.split.1x2",
        blurb: "Where state lives, how it is observed, how it is persisted, and how work happens off the main thread.",
        sections: [
            DemoSection(id: "data.state", title: "State", demos: [
                Demo(
                    id: "data.ownership",
                    title: "State ownership",
                    summary: "@State, @Binding and @Observable side by side.",
                    symbol: "arrow.triangle.branch",
                    notes: DemoNotes(
                        explanation: """
                        A SwiftUI view is a description, not an object: it is recreated constantly, so \
                        values that must survive live in `@State`. A child that needs to write back takes \
                        a `@Binding`. Shared model objects are classes marked `@Observable`, and SwiftUI \
                        re-renders only the views that read a property that changed.
                        """,
                        code: """
                        @Observable final class Counter { var value = 0 }

                        struct Parent: View {
                            @State private var counter = Counter()
                            var body: some View { Child(counter: counter) }
                        }
                        """,
                        apis: ["@State", "@Binding", "@Observable", "@Bindable"]
                    ),
                    content: { StateOwnershipDemo() }
                )
            ])
        ]
    )
}
