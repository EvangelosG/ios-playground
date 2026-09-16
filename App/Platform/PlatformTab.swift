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
                ),
                Demo(
                    id: "platform.photos",
                    title: "Photo picker",
                    summary: "PhotosPicker with no permission prompt, loading images off the main actor.",
                    symbol: "photo.on.rectangle.angled",
                    notes: DemoNotes(
                        explanation: """
                        `PhotosPicker` presents a picker that runs in a separate process, so the app only \
                        ever receives the items the user chose and never needs photo-library access. The \
                        returned `PhotosPickerItem` is a `Transferable` handle: loading the bytes is an \
                        async call, which keeps large images off the main actor.
                        """,
                        code: """
                        PhotosPicker(selection: $selection, maxSelectionCount: 4, matching: .images) {
                            Label("Choose photos", systemImage: "photo")
                        }

                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) { images.append(Image(uiImage: uiImage)) }
                        """,
                        apis: ["PhotosPicker", "PhotosPickerItem", "loadTransferable", "Transferable"]
                    ),
                    content: { PhotoPickerDemo() }
                ),
                Demo(
                    id: "platform.notifications",
                    title: "Local notifications",
                    summary: "Ask for permission, schedule a trigger, inspect the pending queue.",
                    symbol: "bell.badge",
                    notes: DemoNotes(
                        explanation: """
                        Local notifications are scheduled by the app but owned by the system: it stores \
                        the request, fires it on time, and shows it even if the app is not running. \
                        Authorization is asked for once, and everything else — triggers, the pending \
                        queue, cancellation — goes through `UNUserNotificationCenter`. Unlike remote \
                        push, this works fully in the Simulator.
                        """,
                        code: """
                        _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])

                        let request = UNNotificationRequest(
                            identifier: UUID().uuidString,
                            content: content,
                            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                        )
                        try await center.add(request)
                        """,
                        apis: ["UNUserNotificationCenter", "UNNotificationRequest", "UNTimeIntervalNotificationTrigger"]
                    ),
                    content: { NotificationsDemo() }
                )
            ]),
            DemoSection(id: "platform.frameworks", title: "System frameworks", demos: [
                Demo(
                    id: "platform.charts",
                    title: "Swift Charts",
                    summary: "Bar, line and area marks over one series, with touch selection.",
                    symbol: "chart.xyaxis.line",
                    notes: DemoNotes(
                        explanation: """
                        Swift Charts is SwiftUI for data: you describe marks over a collection and it \
                        derives axes, scales and legends. Because `foregroundStyle(by:)` takes a data \
                        value rather than a colour, series colouring and the legend stay in sync \
                        automatically, and swapping `BarMark` for `LineMark` changes nothing else.
                        """,
                        code: """
                        Chart(readings) { reading in
                            BarMark(x: .value("Day", reading.day, unit: .day),
                                    y: .value("Minutes", reading.value))
                                .foregroundStyle(by: .value("Activity", reading.category))
                        }
                        .chartXSelection(value: $selectedDay)
                        """,
                        apis: ["Chart", "BarMark", "LineMark", "AreaMark", "chartXSelection"]
                    ),
                    content: { ChartsDemo() }
                ),
                Demo(
                    id: "platform.map",
                    title: "MapKit",
                    summary: "Markers, a bound camera and map styles — no location permission needed.",
                    symbol: "map",
                    layout: .plain,
                    notes: DemoNotes(
                        explanation: """
                        The SwiftUI `Map` takes a binding to a `MapCameraPosition`, so moving the camera \
                        is a state change you can animate like any other. Content — markers, annotations, \
                        polylines — is declared in a builder, and selection is just a tag binding. \
                        Showing a map needs no permission; only the user's own location does.
                        """,
                        code: """
                        Map(position: $position, selection: $selection) {
                            Marker(place.name, systemImage: place.symbol, coordinate: place.coordinate)
                                .tag(place.id)
                            MapPolyline(coordinates: route).stroke(.blue, lineWidth: 4)
                        }
                        .mapStyle(.standard(elevation: .realistic))
                        """,
                        apis: ["Map", "MapCameraPosition", "Marker", "MapPolyline", "mapStyle"]
                    ),
                    content: { MapDemo() }
                ),
                Demo(
                    id: "platform.formatting",
                    title: "Localisation & formatting",
                    summary: "One data set formatted for five locales, plus RTL mirroring.",
                    symbol: "globe",
                    notes: DemoNotes(
                        explanation: """
                        Never build a user-visible string by hand. Swift's format styles know about \
                        currency placement, decimal separators, measurement systems, date order and list \
                        conjunctions per locale, and SwiftUI passes the locale down through the \
                        environment. Laying out with leading/trailing rather than left/right means the \
                        same view mirrors correctly for right-to-left languages.
                        """,
                        code: """
                        amount.formatted(.currency(code: "EUR").locale(locale))
                        date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale))
                        items.formatted(.list(type: .and).locale(locale))

                        view.environment(\\.layoutDirection, .rightToLeft)
                        """,
                        apis: ["FormatStyle", "Locale", "Measurement", "layoutDirection"]
                    ),
                    content: { FormattingDemo() }
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
