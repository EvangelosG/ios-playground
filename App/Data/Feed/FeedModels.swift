import Foundation

struct FeedItem: Identifiable, Hashable, Codable, Sendable {
    let id: Int
    let title: String
    let author: String
    let publishedAt: Date
}

enum FeedError: LocalizedError, Equatable {
    case offline
    case server(status: Int)

    var errorDescription: String? {
        switch self {
        case .offline: "The network looks offline."
        case .server(let status): "The server returned \(status)."
        }
    }

    var recoverySuggestion: String? {
        "This is a simulated failure — tap Retry to load the mock data."
    }
}

/// The seam that makes the feed testable: production code and tests both depend
/// on the protocol, never on a concrete client.
protocol FeedClient: Sendable {
    func page(after cursor: Int?, pageSize: Int) async throws -> [FeedItem]
}

/// Deterministic offline client. `failureMode` lets the UI (and the tests) drive
/// every branch of the loading state machine without a network.
struct MockFeedClient: FeedClient {
    enum FailureMode: String, CaseIterable, Sendable {
        case none = "Succeed"
        case empty = "Return empty"
        case failure = "Fail"
    }

    var failureMode: FailureMode = .none
    var latency: Duration = .milliseconds(450)
    var total: Int = 24

    func page(after cursor: Int?, pageSize: Int) async throws -> [FeedItem] {
        try await Task.sleep(for: latency)
        switch failureMode {
        case .failure: throw FeedError.server(status: 503)
        case .empty: return []
        case .none: break
        }
        let start = cursor ?? 0
        guard start < total else { return [] }
        let end = min(start + pageSize, total)
        return (start..<end).map { index in
            FeedItem(
                id: index,
                title: MockFeedClient.titles[index % MockFeedClient.titles.count],
                author: MockFeedClient.authors[index % MockFeedClient.authors.count],
                publishedAt: Date(timeIntervalSince1970: 1_750_000_000 - Double(index) * 3_600)
            )
        }
    }

    private static let titles = [
        "Liquid Glass, explained", "Observation vs ObservableObject", "SwiftData in 10 minutes",
        "Structured concurrency patterns", "Custom Layout protocol", "Testing SwiftUI views",
        "Scroll transitions", "Swift 6 data race safety"
    ]

    private static let authors = ["Ada", "Grace", "Linus", "Margaret", "Alan"]
}
