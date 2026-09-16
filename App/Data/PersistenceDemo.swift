import SwiftUI

struct Preferences: Codable, Equatable, Sendable {
    var displayName: String = "Guest"
    var theme: String = "system"
    var launches: Int = 0
}

/// Small Codable-to-disk store. Kept free of SwiftUI so the tests can exercise
/// the round trip in a temporary directory.
struct PreferencesStore: Sendable {
    let url: URL

    init(directory: URL = URL.documentsDirectory, filename: String = "preferences.json") {
        self.url = directory.appending(path: filename)
    }

    func load() throws -> Preferences {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
            return Preferences()
        }
        return try JSONDecoder().decode(Preferences.self, from: Data(contentsOf: url))
    }

    func save(_ preferences: Preferences) throws {
        let data = try JSONEncoder().encode(preferences)
        try data.write(to: url, options: .atomic)
    }

    func clear() throws {
        try? FileManager.default.removeItem(at: url)
    }
}

/// Three persistence tiers side by side: UserDefaults for small values, a JSON
/// file for structured data, and in-memory state that disappears on relaunch.
struct PersistenceDemo: View {
    @AppStorage("playground.nickname") private var nickname = ""
    @AppStorage("playground.soundsOn") private var soundsOn = true
    @State private var preferences = Preferences()
    @State private var status = "Not loaded yet."
    @State private var ephemeral = 0

    private let store = PreferencesStore()

    var body: some View {
        DemoCard("@AppStorage", caption: "A typed window onto UserDefaults. Values survive relaunch automatically.") {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Nickname", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                Toggle("Sounds", isOn: $soundsOn)
                Text("Stored under playground.nickname / playground.soundsOn")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        DemoCard("Codable → JSON file", caption: "Structured data written atomically into the app's Documents directory.") {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Display name", text: $preferences.displayName)
                    .textFieldStyle(.roundedBorder)
                Picker("Theme", selection: $preferences.theme) {
                    ForEach(["system", "light", "dark"], id: \.self) { Text($0.capitalized).tag($0) }
                }
                .pickerStyle(.segmented)
                HStack {
                    Button("Save") { perform { try store.save(preferences); status = "Saved to \(store.url.lastPathComponent)." } }
                        .buttonStyle(.borderedProminent)
                    Button("Load") { perform { preferences = try store.load(); status = "Loaded from disk." } }
                    Button("Clear", role: .destructive) { perform { try store.clear(); preferences = Preferences(); status = "File removed." } }
                }
                Text(status).font(.caption).foregroundStyle(.secondary)
            }
        }

        DemoCard("@State", caption: "Lives only as long as the view does — the contrast that makes the others obvious.") {
            Stepper("Ephemeral counter: \(ephemeral)", value: $ephemeral)
        }

        TryItNote("Save a display name, leave the screen and come back: @State resets, the file and defaults do not.")
    }

    private func perform(_ work: () throws -> Void) {
        do {
            try work()
        } catch {
            status = error.localizedDescription
        }
    }
}

#Preview {
    ScrollView { VStack { PersistenceDemo() }.padding() }
}
