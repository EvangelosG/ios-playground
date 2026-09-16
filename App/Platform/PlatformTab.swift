import SwiftUI

@MainActor
enum PlatformTab {
    static let tab = DemoTab(
        id: "platform",
        title: "Platform",
        symbol: "gearshape.2",
        blurb: "System integration: sharing, haptics, maps, charts, notifications, localisation and app lifecycle.",
        sections: [
            DemoSection(id: "platform.system", title: "System integration", demos: [
                Demo(
                    id: "platform.share",
                    title: "Sharing & haptics",
                    summary: "The share sheet and system feedback, with no custom UI to maintain.",
                    symbol: "square.and.arrow.up",
                    notes: DemoNotes(
                        explanation: """
                        `ShareLink` hands a value to the system share sheet — the same sheet every other \
                        app uses, so users already know it. `sensoryFeedback` asks the system for the \
                        right haptic for a result rather than hard-coding a vibration pattern.
                        """,
                        code: """
                        ShareLink(item: url, subject: Text("iOS Playground"))

                        view.sensoryFeedback(.success, trigger: completedCount)
                        """,
                        apis: ["ShareLink", "sensoryFeedback(_:trigger:)", "Transferable"]
                    ),
                    content: { SharingDemo() }
                )
            ]),
            DemoSection(id: "platform.device", title: "Needs real hardware", demos: [
                Demo(
                    id: "platform.deviceonly",
                    title: "Device-only features",
                    summary: "What this playground deliberately leaves out, and why.",
                    symbol: "iphone.gen3",
                    notes: DemoNotes(
                        explanation: """
                        Some frameworks cannot be exercised meaningfully in the Simulator because there \
                        is no sensor, secure enclave, or APNs token behind them. They are listed here so \
                        their absence is a decision rather than a gap.
                        """,
                        code: "// Nothing to run here — see the list on screen.",
                        apis: ["AVCaptureSession", "LocalAuthentication", "ARKit", "HealthKit"]
                    ),
                    content: { DeviceOnlyDemo() }
                )
            ])
        ]
    )
}
