import SwiftUI

struct TypographyDemo: View {
    @State private var symbolBounce = 0
    @State private var isFavourite = false

    private let styles: [(String, Font)] = [
        ("largeTitle", .largeTitle),
        ("title", .title),
        ("title2", .title2),
        ("headline", .headline),
        ("body", .body),
        ("callout", .callout),
        ("subheadline", .subheadline),
        ("footnote", .footnote),
        ("caption", .caption)
    ]

    var body: some View {
        DemoCard("Text styles", caption: "Semantic styles, not point sizes — they resize with the reader's Dynamic Type setting.") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(styles, id: \.0) { name, font in
                    HStack(alignment: .firstTextBaseline) {
                        Text("Aa")
                            .font(font)
                        Text(".\(name)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            TryItNote("Settings › Accessibility › Display & Text Size changes every line above.")
        }

        DemoCard("Dynamic Type preview", caption: "The same card at three content sizes.") {
            ForEach([DynamicTypeSize.small, .large, .accessibility2], id: \.self) { size in
                Label("Weekly summary", systemImage: "calendar")
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background.tertiary, in: .rect(cornerRadius: 8))
                    .dynamicTypeSize(size)
            }
        }

        DemoCard("SF Symbols", caption: "One font-like icon set: hierarchical rendering, variable colour, and animated effects.") {
            HStack(spacing: 20) {
                Image(systemName: "cloud.sun.rain.fill")
                    .symbolRenderingMode(.multicolor)
                Image(systemName: "wifi", variableValue: 0.4)
                Image(systemName: "bell.fill")
                    .symbolEffect(.bounce, value: symbolBounce)
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(isFavourite ? .pink : .secondary)
            }
            .font(.largeTitle)

            HStack {
                Button("Bounce") { symbolBounce += 1 }
                Button(isFavourite ? "Unfavourite" : "Favourite") {
                    withAnimation { isFavourite.toggle() }
                }
            }
            .buttonStyle(.bordered)
        }

        DemoCard("Formatting", caption: "Dates, measurements and currency format themselves for the reader's locale.") {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                Text(1234.56, format: .currency(code: "USD"))
                Text(Measurement(value: 12.4, unit: UnitLength.kilometers), format: .measurement(width: .abbreviated))
                Text(0.732, format: .percent.precision(.fractionLength(1)))
            }
            .monospacedDigit()
        }
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { TypographyDemo() }.padding() }
}
