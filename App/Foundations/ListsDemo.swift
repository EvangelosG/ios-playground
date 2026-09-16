import SwiftUI

struct ListsDemo: View {
    struct Chore: Identifiable, Hashable {
        let id = UUID()
        var title: String
        var isDone = false
        var isFlagged = false
    }

    @State private var tasks: [Chore] = [
        Chore(title: "Design review"),
        Chore(title: "Fix the scroll jank", isFlagged: true),
        Chore(title: "Ship the beta"),
        Chore(title: "Write release notes"),
        Chore(title: "Archive old branches", isDone: true)
    ]
    @State private var selection = Set<Chore.ID>()
    @State private var lastRefresh = Date.now

    private var open: [Chore] { tasks.filter { !$0.isDone } }
    private var done: [Chore] { tasks.filter(\.isDone) }

    var body: some View {
        List(selection: $selection) {
            Section {
                Text("Pull down to refresh, swipe a row either way, long-press for a menu, or tap Edit to reorder.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Open") {
                ForEach(open) { task in
                    row(for: task)
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }

            Section("Done") {
                ForEach(done) { task in
                    row(for: task)
                }
            }

            Section {
                LabeledContent("Last refreshed", value: lastRefresh, format: .dateTime.hour().minute().second())
                    .font(.footnote)
            }
        }
        .refreshable {
            try? await Task.sleep(for: .milliseconds(600))
            lastRefresh = .now
        }
        .toolbar {
            EditButton()
        }
    }

    private func row(for task: Chore) -> some View {
        HStack {
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isDone ? .green : .secondary)
            Text(task.title)
                .strikethrough(task.isDone)
            Spacer()
            if task.isFlagged {
                Image(systemName: "flag.fill").foregroundStyle(.orange)
            }
        }
        .contentShape(.rect)
        .onTapGesture { toggleDone(task) }
        .swipeActions(edge: .leading) {
            Button("Flag", systemImage: "flag") { toggleFlag(task) }
                .tint(.orange)
        }
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) { remove(task) }
            Button(task.isDone ? "Reopen" : "Complete", systemImage: "checkmark") { toggleDone(task) }
                .tint(.green)
        }
        .contextMenu {
            Button("Duplicate", systemImage: "plus.square.on.square") { duplicate(task) }
            Button("Delete", systemImage: "trash", role: .destructive) { remove(task) }
        }
    }

    private func index(of task: Chore) -> Int? {
        tasks.firstIndex { $0.id == task.id }
    }

    private func toggleDone(_ task: Chore) {
        guard let index = index(of: task) else { return }
        withAnimation { tasks[index].isDone.toggle() }
    }

    private func toggleFlag(_ task: Chore) {
        guard let index = index(of: task) else { return }
        withAnimation { tasks[index].isFlagged.toggle() }
    }

    private func duplicate(_ task: Chore) {
        guard let index = index(of: task) else { return }
        withAnimation { tasks.insert(Chore(title: task.title + " copy"), at: index) }
    }

    private func remove(_ task: Chore) {
        withAnimation { tasks.removeAll { $0.id == task.id } }
    }

    private func delete(at offsets: IndexSet) {
        let ids = offsets.map { open[$0].id }
        withAnimation { tasks.removeAll { ids.contains($0.id) } }
    }

    private func move(from offsets: IndexSet, to destination: Int) {
        var reordered = open
        reordered.move(fromOffsets: offsets, toOffset: destination)
        tasks = reordered + done
    }
}

#Preview {
    NavigationStack { ListsDemo() }
}
