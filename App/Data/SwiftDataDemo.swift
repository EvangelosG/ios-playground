import SwiftData
import SwiftUI

@Model
final class Note {
    var title: String
    var body: String
    var createdAt: Date
    var isPinned: Bool
    @Relationship(deleteRule: .cascade, inverse: \NoteTag.note)
    var tags: [NoteTag]

    init(title: String, body: String = "", createdAt: Date = .now, isPinned: Bool = false) {
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.tags = []
    }
}

@Model
final class NoteTag {
    var name: String
    var note: Note?

    init(name: String) {
        self.name = name
    }
}

/// SwiftData CRUD against an in-memory store, so the demo starts from a known
/// state every launch and never leaves anything on disk.
struct SwiftDataDemo: View {
    var body: some View {
        NoteList()
            .modelContainer(SwiftDataDemo.previewContainer)
    }

    @MainActor
    static let previewContainer: ModelContainer = {
        let container = try! ModelContainer(
            for: Note.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        for seed in ["Groceries", "Reading list", "Standup notes"] {
            container.mainContext.insert(Note(title: seed, body: "Seeded on first launch."))
        }
        return container
    }()
}

private struct NoteList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]

    @State private var draft = ""

    private var ordered: [Note] {
        notes.sorted { ($0.isPinned ? 1 : 0, $0.createdAt) > ($1.isPinned ? 1 : 0, $1.createdAt) }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("New note", text: $draft)
                        .onSubmit(add)
                        .accessibilityIdentifier("noteField")
                    Button("Add", action: add)
                        .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } footer: {
                Text("Stored in an in-memory SwiftData container: @Query re-runs itself whenever the context changes.")
            }

            if ordered.isEmpty {
                ContentUnavailableView("No notes", systemImage: "note.text", description: Text("Add one above."))
            }

            ForEach(ordered) { note in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        if note.isPinned {
                            Image(systemName: "pin.fill").foregroundStyle(.orange)
                        }
                        Text(note.title)
                    }
                    Text(note.createdAt, format: .dateTime.hour().minute().second())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .swipeActions(edge: .leading) {
                    Button(note.isPinned ? "Unpin" : "Pin", systemImage: "pin") {
                        note.isPinned.toggle()
                    }
                    .tint(.orange)
                }
                .swipeActions(edge: .trailing) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        context.delete(note)
                    }
                }
            }
        }
    }

    private func add() {
        let title = draft.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        withAnimation { context.insert(Note(title: title)) }
        draft = ""
    }
}

#Preview {
    NavigationStack { SwiftDataDemo() }
}
