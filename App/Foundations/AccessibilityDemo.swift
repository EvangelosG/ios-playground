import SwiftUI

struct AccessibilityDemo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var typeSize

    @State private var progress = 0.4
    @State private var spin = false

    var body: some View {
        DemoCard("What the system tells the app") {
            LabeledContent("Size class", value: sizeClass == .compact ? "compact" : "regular")
            LabeledContent("Colour scheme", value: colorScheme == .dark ? "dark" : "light")
            LabeledContent("Dynamic Type", value: String(describing: typeSize))
            LabeledContent("Reduce Motion", value: reduceMotion ? "on" : "off")
        }

        DemoCard("One element, not five", caption: "Grouping turns a decorative row into a single sentence VoiceOver can read.") {
            HStack {
                Image(systemName: "drop.fill").foregroundStyle(.blue)
                VStack(alignment: .leading) {
                    Text("Water")
                    Text("1.2 of 3 litres").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                ProgressView(value: progress)
                    .frame(width: 80)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Water intake")
            .accessibilityValue("1.2 of 3 litres")
            .accessibilityHint("Double tap to log a glass")
            .accessibilityAddTraits(.isButton)

            TryItNote("Turn on VoiceOver: this row is announced as one item, not four fragments.")
        }

        DemoCard("Respecting Reduce Motion", caption: "The same state change, animated or instant depending on the setting.") {
            Image(systemName: "gearshape.fill")
                .font(.largeTitle)
                .rotationEffect(.degrees(spin ? 360 : 0))
                .animation(reduceMotion ? nil : .easeInOut(duration: 1), value: spin)
            Button("Rotate") { spin.toggle() }
                .buttonStyle(.bordered)
        }

        DemoCard("Colour is never the only signal", caption: "Status is conveyed by symbol and text as well as hue.") {
            VStack(alignment: .leading, spacing: 8) {
                statusRow(.green, "checkmark.circle.fill", "Healthy")
                statusRow(.orange, "exclamationmark.triangle.fill", "Degraded")
                statusRow(.red, "xmark.octagon.fill", "Offline")
            }
        }
    }

    private func statusRow(_ color: Color, _ symbol: String, _ label: String) -> some View {
        Label(label, systemImage: symbol)
            .foregroundStyle(color)
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { AccessibilityDemo() }.padding() }
}
