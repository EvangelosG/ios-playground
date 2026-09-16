import SwiftUI

struct SharingDemo: View {
    @State private var tapCount = 0

    private let url = URL(string: "https://developer.apple.com/documentation/swiftui")!

    var body: some View {
        DemoCard("ShareLink", caption: "Opens the system share sheet with a URL.") {
            ShareLink(item: url, subject: Text("SwiftUI documentation")) {
                Label("Share a link", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("shareLink")
        }

        DemoCard("Sensory feedback", caption: "Haptics are silent in the Simulator, but the trigger pattern is the point.") {
            Button("Report success") { tapCount += 1 }
                .buttonStyle(.bordered)
                .sensoryFeedback(.success, trigger: tapCount)
            Text("Fired \(tapCount) time\(tapCount == 1 ? "" : "s")")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

struct DeviceOnlyDemo: View {
    private struct Item: Identifiable {
        let id = UUID()
        let name: String
        let symbol: String
        let reason: String
    }

    private let items: [Item] = [
        Item(name: "Camera capture", symbol: "camera", reason: "The Simulator has no camera feed to capture."),
        Item(name: "Face ID / Touch ID", symbol: "faceid", reason: "Enrolment is simulated, so a real result cannot be shown."),
        Item(name: "Remote push notifications", symbol: "bell.badge", reason: "Needs an APNs device token and a server."),
        Item(name: "HealthKit", symbol: "heart.text.square", reason: "No health store on a simulated device."),
        Item(name: "ARKit", symbol: "arkit", reason: "Requires camera and motion sensors."),
        Item(name: "Live Activities", symbol: "sparkles.rectangle.stack", reason: "Depends on push-driven updates.")
    ]

    var body: some View {
        DemoCard("Left out on purpose", caption: "Everything else in this app runs in the Simulator.") {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(items) { item in
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                            Text(item.reason)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: item.symbol)
                            .foregroundStyle(.tint)
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { SharingDemo() }.padding() }
}
