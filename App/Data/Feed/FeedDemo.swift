import SwiftUI

/// Every state a networked list can be in — loading, empty, error, loaded and
/// loading-more — driven by a mock client you can switch between outcomes.
struct FeedDemo: View {
    @State private var model = FeedViewModel()
    @State private var failureMode: MockFeedClient.FailureMode = .none

    var body: some View {
        VStack(spacing: 0) {
            Picker("Mock response", selection: $failureMode) {
                ForEach(MockFeedClient.FailureMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: failureMode) { _, mode in
                model.client = MockFeedClient(failureMode: mode)
                Task { await model.load() }
            }

            content
        }
        .task {
            model.client = MockFeedClient(failureMode: failureMode)
            await model.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading…").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load the feed", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") { Task { await model.load() } }
                    .buttonStyle(.borderedProminent)
            }

        case .loaded(let items) where items.isEmpty:
            ContentUnavailableView("Nothing here yet", systemImage: "tray", description: Text("The mock client returned an empty page."))

        case .loaded(let items):
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                        Text("\(item.author) · \(item.publishedAt, format: .dateTime.month().day())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if model.hasMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .task { await model.loadMore() }
                } else {
                    Text("End of feed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .refreshable { await model.refresh() }
        }
    }
}

#Preview {
    NavigationStack { FeedDemo() }
}
