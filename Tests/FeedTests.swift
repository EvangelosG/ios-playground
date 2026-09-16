import Foundation
import Testing
@testable import iOSPlayground

struct MockFeedClientTests {
    @Test func returnsRequestedPageSize() async throws {
        let client = MockFeedClient(latency: .zero, total: 20)
        let page = try await client.page(after: nil, pageSize: 8)
        #expect(page.count == 8)
        #expect(page.first?.id == 0)
    }

    @Test func pagesFromCursorAndStopsAtTheEnd() async throws {
        let client = MockFeedClient(latency: .zero, total: 10)
        let second = try await client.page(after: 8, pageSize: 8)
        #expect(second.count == 2)
        #expect(try await client.page(after: 10, pageSize: 8).isEmpty)
    }

    @Test func failureModesAreHonoured() async throws {
        let empty = MockFeedClient(failureMode: .empty, latency: .zero)
        #expect(try await empty.page(after: nil, pageSize: 4).isEmpty)

        let failing = MockFeedClient(failureMode: .failure, latency: .zero)
        await #expect(throws: FeedError.server(status: 503)) {
            _ = try await failing.page(after: nil, pageSize: 4)
        }
    }
}

@MainActor
struct FeedViewModelTests {
    private func model(_ mode: MockFeedClient.FailureMode = .none, total: Int = 24, pageSize: Int = 8) -> FeedViewModel {
        FeedViewModel(client: MockFeedClient(failureMode: mode, latency: .zero, total: total), pageSize: pageSize)
    }

    @Test func loadPopulatesTheFirstPage() async {
        let model = model()
        await model.load()
        #expect(model.items.count == 8)
        #expect(model.hasMore)
    }

    @Test func loadMoreAppendsAndStopsAtTheEnd() async {
        let model = model(total: 12)
        await model.load()
        await model.loadMore()
        #expect(model.items.count == 12)
        #expect(!model.hasMore)

        await model.loadMore()
        #expect(model.items.count == 12)
    }

    @Test func failureSurfacesAsFailedState() async {
        let model = model(.failure)
        await model.load()
        guard case .failed(let message) = model.state else {
            Issue.record("expected failed state, got \(model.state)")
            return
        }
        #expect(message.contains("503"))
        #expect(model.items.isEmpty)
    }

    @Test func emptyResponseLoadsAnEmptyPage() async {
        let model = model(.empty)
        await model.load()
        #expect(model.state == .loaded([]))
        #expect(!model.hasMore)
    }

    @Test func refreshReplacesRatherThanAppends() async {
        let model = model()
        await model.load()
        await model.loadMore()
        #expect(model.items.count == 16)
        await model.refresh()
        #expect(model.items.count == 8)
    }
}
