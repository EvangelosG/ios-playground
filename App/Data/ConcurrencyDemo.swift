import SwiftUI

/// Actors serialise access to mutable state, so concurrent callers can never
/// tear it — the compiler enforces the hop under Swift 6 strict concurrency.
actor DownloadTracker {
    private(set) var completed: [Int] = []

    func record(_ id: Int) -> [Int] {
        completed.append(id)
        return completed.sorted()
    }

    func reset() {
        completed.removeAll()
    }
}

/// Runs five "downloads" in a task group so they overlap instead of queueing,
/// and shows what cancellation actually does to work in flight.
struct ConcurrencyDemo: View {
    @State private var progress: [Int: Double] = [:]
    @State private var finished: [Int] = []
    @State private var isRunning = false
    @State private var log: [String] = []

    private let tracker = DownloadTracker()
    private let ids = Array(1...5)

    var body: some View {
        DemoCard("Task group", caption: "Five jobs started together; the group waits for all of them.") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(ids, id: \.self) { id in
                    HStack {
                        Text("Job \(id)").font(.callout.monospaced())
                        ProgressView(value: progress[id] ?? 0)
                        Image(systemName: finished.contains(id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(finished.contains(id) ? .green : .secondary)
                    }
                }

                HStack {
                    Button(isRunning ? "Running…" : "Start", systemImage: "play.fill") { start() }
                        .buttonStyle(.borderedProminent)
                        .disabled(isRunning)
                    Button("Cancel", systemImage: "stop.fill", role: .destructive) { cancel() }
                        .disabled(!isRunning)
                }
            }
        }

        DemoCard("What happened", caption: "Cancellation is cooperative: each job checks for it and stops early.") {
            if log.isEmpty {
                Text("Start the jobs to see the log.").foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(log, id: \.self) { line in
                        Text(line).font(.caption.monospaced())
                    }
                }
            }
        }

        TryItNote("Start the jobs, then hit Cancel halfway through and watch the log.")
    }

    @State private var work: Task<Void, Never>?

    private func start() {
        work?.cancel()
        progress = [:]
        finished = []
        log = []
        isRunning = true
        work = Task {
            await tracker.reset()
            await withTaskGroup(of: Void.self) { group in
                for id in ids {
                    group.addTask { await run(id: id) }
                }
            }
            isRunning = false
            log.append(Task.isCancelled ? "group cancelled" : "group finished")
        }
    }

    private func cancel() {
        work?.cancel()
    }

    private func run(id: Int) async {
        for step in 1...10 {
            do {
                try await Task.sleep(for: .milliseconds(80 * id / 2 + 60))
            } catch {
                log.append("job \(id) cancelled at \(step * 10)%")
                return
            }
            progress[id] = Double(step) / 10
        }
        finished = await tracker.record(id)
        log.append("job \(id) done")
    }
}

#Preview {
    ScrollView { VStack { ConcurrencyDemo() }.padding() }
}
