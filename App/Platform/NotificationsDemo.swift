import SwiftUI
import UserNotifications

/// Local notifications work fully in the Simulator: request authorization,
/// schedule a time-interval trigger, then inspect or cancel what is pending.
@MainActor
@Observable
final class NotificationScheduler {
    private(set) var authorization: UNAuthorizationStatus = .notDetermined
    private(set) var pending: [String] = []
    private(set) var lastError: String?

    private let center = UNUserNotificationCenter.current()

    func refresh() async {
        authorization = await center.notificationSettings().authorizationStatus
        pending = await center.pendingNotificationRequests().map(\.content.title)
    }

    func requestAuthorization() async {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            lastError = error.localizedDescription
        }
        await refresh()
    }

    func schedule(title: String, after seconds: TimeInterval) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Scheduled \(Int(seconds))s ago from the playground."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        )
        do {
            try await center.add(request)
        } catch {
            lastError = error.localizedDescription
        }
        await refresh()
    }

    func cancelAll() async {
        center.removeAllPendingNotificationRequests()
        await refresh()
    }
}

struct NotificationsDemo: View {
    @State private var scheduler = NotificationScheduler()
    @State private var delay: Double = 5
    @State private var title = "Time to tap something"

    var body: some View {
        DemoCard("Authorization", caption: "Nothing can be scheduled until the user agrees.") {
            VStack(alignment: .leading, spacing: 10) {
                LabeledContent("Status", value: describe(scheduler.authorization))
                Button("Request permission") { Task { await scheduler.requestAuthorization() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(scheduler.authorization == .authorized)
            }
        }

        DemoCard("Schedule", caption: "A time-interval trigger; background the app to see the banner.") {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Text("In \(Int(delay))s")
                        .monospacedDigit()
                    Slider(value: $delay, in: 2...30, step: 1)
                }
                HStack {
                    Button("Schedule") { Task { await scheduler.schedule(title: title, after: delay) } }
                        .buttonStyle(.bordered)
                        .disabled(scheduler.authorization != .authorized)
                    Button("Cancel all", role: .destructive) { Task { await scheduler.cancelAll() } }
                        .disabled(scheduler.pending.isEmpty)
                }
            }
        }

        DemoCard("Pending", caption: "The system holds the queue; the app can only query it.") {
            if scheduler.pending.isEmpty {
                Text("Nothing scheduled.").foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(scheduler.pending.enumerated()), id: \.offset) { _, title in
                        Label(title, systemImage: "bell.badge")
                            .font(.callout)
                    }
                }
            }
        }

        if let error = scheduler.lastError {
            Text(error).font(.caption).foregroundStyle(.red)
        }

        TryItNote("Schedule one, then swipe the app to the background before the timer fires.")
            .task { await scheduler.refresh() }
    }

    private func describe(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: "Not determined"
        case .denied: "Denied"
        case .authorized: "Authorized"
        case .provisional: "Provisional"
        case .ephemeral: "Ephemeral"
        @unknown default: "Unknown"
        }
    }
}

#Preview {
    ScrollView { VStack { NotificationsDemo() }.padding() }
}
