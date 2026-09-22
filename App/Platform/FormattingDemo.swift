import Foundation
import SwiftUI

/// Locale-aware formatting helpers, kept separate from the view so the tests can
/// pin them to specific locales.
enum PlaygroundFormatters {
    static func currency(_ amount: Decimal, locale: Locale) -> String {
        amount.formatted(.currency(code: locale.currency?.identifier ?? "USD").locale(locale))
    }

    static func list(_ items: [String], locale: Locale) -> String {
        items.formatted(.list(type: .and).locale(locale))
    }

    static func measurement(_ metres: Double, locale: Locale) -> String {
        Measurement(value: metres, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road).locale(locale))
    }
}

/// Everything user-visible goes through a formatter or a localized string, so
/// the same code reads correctly in every region.
struct FormattingDemo: View {
    private let locales = ["en_US", "en_GB", "de_DE", "fr_FR", "ja_JP"].map(Locale.init(identifier:))

    @State private var localeID = "en_US"
    @State private var amount: Double = 1234.5
    @State private var distance: Double = 4_200

    private var locale: Locale { Locale(identifier: localeID) }
    private let reference = Date(timeIntervalSince1970: 1_750_000_000)

    var body: some View {
        DemoCard("Locale", caption: "Pick a region and watch every value below re-format.") {
            Picker("Locale", selection: $localeID) {
                ForEach(locales, id: \.identifier) { locale in
                    Text(locale.identifier).tag(locale.identifier)
                }
            }
            .pickerStyle(.segmented)
        }

        DemoCard("Numbers, money, units") {
            VStack(alignment: .leading, spacing: 10) {
                Slider(value: $amount, in: 0...10_000)
                LabeledContent("Currency", value: PlaygroundFormatters.currency(Decimal(amount), locale: locale))
                LabeledContent("Percent", value: (amount / 10_000).formatted(.percent.precision(.fractionLength(1)).locale(locale)))
                Slider(value: $distance, in: 100...50_000)
                LabeledContent("Distance", value: PlaygroundFormatters.measurement(distance, locale: locale))
            }
        }

        DemoCard("Dates and lists") {
            VStack(alignment: .leading, spacing: 10) {
                LabeledContent("Full", value: reference.formatted(.dateTime.weekday(.wide).day().month(.wide).year().locale(locale)))
                LabeledContent("Short", value: reference.formatted(.dateTime.day().month().year().locale(locale)))
                LabeledContent("Relative", value: (reference.addingTimeInterval(-7_200)).formatted(.relative(presentation: .named).locale(locale)))
                LabeledContent("List", value: PlaygroundFormatters.list(["coffee", "tea", "water"], locale: locale))
            }
        }

        DemoCard("Layout direction", caption: "Leading/trailing beats left/right: the same view mirrors for RTL languages.") {
            VStack(spacing: 8) {
                ForEach([LayoutDirection.leftToRight, .rightToLeft], id: \.self) { direction in
                    HStack {
                        Image(systemName: "arrow.forward.circle.fill")
                        Text(direction == .leftToRight ? "Left to right" : "Right to left")
                        Spacer()
                        Text("42").monospacedDigit()
                    }
                    .padding(10)
                    .background(.background.secondary, in: .rect(cornerRadius: 10))
                    .environment(\.layoutDirection, direction)
                }
            }
        }

        TryItNote("Switch to ja_JP or de_DE — separators, currency position and date order all change.")
    }
}

#Preview {
    ScrollView { VStack { FormattingDemo() }.padding() }
}
