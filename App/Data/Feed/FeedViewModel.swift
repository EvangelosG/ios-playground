import Foundation
import Observation

/// The four states every networked screen has to render. Modelling them as one
/// enum makes "loading and error at the same time" unrepresentable.
enum LoadState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

@MainActor
@Observable
final class FeedViewModel {
    private(set) var state: LoadState<[FeedItem]> = .idle
    private(set) var isLoadingMore = false
    private(set) var hasMore = true

    var client: FeedClient
    let pageSize: Int

    private var loadTask: Task<Void, Never>?

    init(client: FeedClient = MockFeedClient(), pageSize: Int = 8) {
        self.client = client
        self.pageSize = pageSize
    }

    var items: [FeedItem] {
        if case .loaded(let items) = state { return items }
        return []
    }

    func load() async {
        loadTask?.cancel()
        state = .loading
        hasMore = true
        await run {
            let page = try await self.client.page(after: nil, pageSize: self.pageSize)
            self.state = .loaded(page)
            self.hasMore = page.count == self.pageSize
        }
    }

    func loadMore() async {
        guard case .loaded(let existing) = state, hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        await run {
            let page = try await self.client.page(after: existing.count, pageSize: self.pageSize)
            self.state = .loaded(existing + page)
            self.hasMore = page.count == self.pageSize
        }
    }

    /// `refreshable` cancels this task when the user lets go of the gesture, so
    /// a cancelled load must not overwrite the screen with an error.
    func refresh() async {
        await load()
    }

    func cancel() {
        loadTask?.cancel()
        if case .loading = state { state = .idle }
    }

    private func run(_ operation: @escaping @MainActor () async throws -> Void) async {
        let task = Task { @MainActor in
            do {
                try await operation()
            } catch is CancellationError {
                // Cancellation is a normal outcome, not a failure to report.
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
        loadTask = task
        await task.value
    }
}
