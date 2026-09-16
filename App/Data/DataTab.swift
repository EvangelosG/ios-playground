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
            ]),
            DemoSection(id: "data.storage", title: "Storage", demos: [
                Demo(
                    id: "data.swiftdata",
                    title: "SwiftData",
                    summary: "Models, @Query and a live-updating list backed by a real store.",
                    symbol: "externaldrive.badge.icloud",
                    layout: .plain,
                    notes: DemoNotes(
                        explanation: """
                        SwiftData is the current persistence framework: annotate a class with `@Model` \
                        and it becomes a stored entity with change tracking and relationships. Views read \
                        it with `@Query`, which is a live view of the store — inserting or deleting through \
                        the `ModelContext` updates every query automatically, no reload call needed. This \
                        demo uses an in-memory container so it starts clean each launch.
                        """,
                        code: """
                        @Model final class Note {
                            var title: String
                            var isPinned: Bool
                            init(title: String) { self.title = title; self.isPinned = false }
                        }

                        @Query(sort: \\Note.createdAt, order: .reverse) private var notes: [Note]
                        @Environment(\\.modelContext) private var context

                        context.insert(Note(title: "New"))   // the list updates itself
                        """,
                        apis: ["@Model", "@Query", "ModelContainer", "ModelContext", "@Relationship"]
                    ),
                    content: { SwiftDataDemo() }
                ),
                Demo(
                    id: "data.persistence",
                    title: "Persistence tiers",
                    summary: "@AppStorage, a Codable JSON file, and throwaway @State compared.",
                    symbol: "tray.full",
                    notes: DemoNotes(
                        explanation: """
                        Not everything belongs in a database. Small user preferences go in UserDefaults, \
                        which SwiftUI exposes as `@AppStorage`; structured documents are usually `Codable` \
                        values written to the app's sandboxed Documents directory; and anything that is \
                        purely view state stays in `@State` and is allowed to disappear. Picking the right \
                        tier is most of what "persistence" means in practice.
                        """,
                        code: """
                        @AppStorage("playground.nickname") private var nickname = ""

                        let url = URL.documentsDirectory.appending(path: "preferences.json")
                        try JSONEncoder().encode(preferences).write(to: url, options: .atomic)
                        let loaded = try JSONDecoder().decode(Preferences.self, from: Data(contentsOf: url))
                        """,
                        apis: ["@AppStorage", "Codable", "URL.documentsDirectory", "JSONEncoder"]
                    ),
                    content: { PersistenceDemo() }
                )
            ]),
            DemoSection(id: "data.async", title: "Async work", demos: [
                Demo(
                    id: "data.feed",
                    title: "Loading states",
                    summary: "Loading, empty, error, loaded and paging — from a mock client you control.",
                    symbol: "arrow.down.circle",
                    layout: .plain,
                    notes: DemoNotes(
                        explanation: """
                        A networked screen has more states than "has data". Modelling them as a single \
                        enum makes the impossible combinations unrepresentable, and hiding the network \
                        behind a `FeedClient` protocol means the view model can be unit tested with a \
                        deterministic mock — which is exactly what the tests in this repo do. Paging is \
                        just another call with a cursor, triggered by a `.task` on the last row.
                        """,
                        code: """
                        enum LoadState<Value: Equatable>: Equatable {
                            case idle, loading, loaded(Value), failed(String)
                        }

                        protocol FeedClient: Sendable {
                            func page(after cursor: Int?, pageSize: Int) async throws -> [FeedItem]
                        }

                        .task { await model.load() }
                        .refreshable { await model.refresh() }
                        """,
                        apis: ["async/await", "task", "refreshable", "ContentUnavailableView", "@Observable"]
                    ),
                    content: { FeedDemo() }
                ),
                Demo(
                    id: "data.concurrency",
                    title: "Tasks & actors",
                    summary: "Overlapping work in a task group, an actor guarding shared state, and cancellation.",
                    symbol: "arrow.triangle.branch",
                    notes: DemoNotes(
                        explanation: """
                        Structured concurrency ties child tasks to a scope: `withTaskGroup` starts jobs in \
                        parallel and cannot return until they finish, so nothing leaks. Shared mutable state \
                        lives in an `actor`, which serialises access — under Swift 6 the compiler rejects \
                        code that would race. Cancellation is cooperative: `Task.sleep` throws, and each job \
                        decides how to unwind.
                        """,
                        code: """
                        actor DownloadTracker {
                            private(set) var completed: [Int] = []
                            func record(_ id: Int) -> [Int] { completed.append(id); return completed }
                        }

                        await withTaskGroup(of: Void.self) { group in
                            for id in ids { group.addTask { await run(id: id) } }
                        }

                        work?.cancel()   // Task.sleep throws CancellationError
                        """,
                        apis: ["withTaskGroup", "actor", "Task", "Task.sleep", "CancellationError"]
                    ),
                    content: { ConcurrencyDemo() }
                )
            ])
        ]
    )
}
