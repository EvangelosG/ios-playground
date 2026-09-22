import Foundation
import Testing
@testable import iOSPlayground

struct PreferencesStoreTests {
    private func temporaryStore() throws -> PreferencesStore {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return PreferencesStore(directory: directory)
    }

    @Test func loadReturnsDefaultsWhenNothingIsStored() throws {
        let store = try temporaryStore()
        #expect(try store.load() == Preferences())
    }

    @Test func savedPreferencesRoundTrip() throws {
        let store = try temporaryStore()
        let preferences = Preferences(displayName: "Ada", theme: "dark", launches: 3)
        try store.save(preferences)
        #expect(try store.load() == preferences)
    }

    @Test func clearRemovesTheFile() throws {
        let store = try temporaryStore()
        try store.save(Preferences(displayName: "Grace", theme: "light", launches: 1))
        try store.clear()
        #expect(try store.load() == Preferences())
    }
}

struct DownloadTrackerTests {
    @Test func recordsConcurrentCompletionsWithoutLosingAny() async {
        let tracker = DownloadTracker()
        await withTaskGroup(of: Void.self) { group in
            for id in 1...20 {
                group.addTask { _ = await tracker.record(id) }
            }
        }
        #expect(await tracker.completed.count == 20)
        #expect(Set(await tracker.completed) == Set(1...20))
    }
}
