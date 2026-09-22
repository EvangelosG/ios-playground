import Charts
import SwiftUI

struct Reading: Identifiable, Hashable, Sendable {
    let id = UUID()
    let day: Date
    let category: String
    let value: Double
}

/// Deterministic sample series so the chart looks the same on every launch.
enum SampleSeries {
    static func readings(days: Int = 14, reference: Date = Date(timeIntervalSince1970: 1_750_000_000)) -> [Reading] {
        let categories = ["Walking", "Cycling"]
        return (0..<days).flatMap { offset -> [Reading] in
            let day = Calendar(identifier: .gregorian).date(byAdding: .day, value: -offset, to: reference) ?? reference
            return categories.enumerated().map { index, category in
                let base = 40.0 + Double((offset * 7 + index * 23) % 45)
                return Reading(day: day, category: category, value: base)
            }
        }
        .sorted { $0.day < $1.day }
    }

    static func total(_ readings: [Reading], category: String) -> Double {
        readings.filter { $0.category == category }.reduce(0) { $0 + $1.value }
    }
}

/// Swift Charts: the same data drawn three ways, plus selection driven by the
/// chart's own x-axis value.
struct ChartsDemo: View {
    private enum Style: String, CaseIterable {
        case bar = "Bar", line = "Line", area = "Area"
    }

    @State private var style: Style = .bar
    @State private var selectedDay: Date?

    private let readings = SampleSeries.readings()

    var body: some View {
        DemoCard("Swift Charts", caption: "Declarative marks over the same series — swap the mark, keep the data.") {
            VStack(spacing: 12) {
                Picker("Style", selection: $style) {
                    ForEach(Style.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                Chart(readings) { reading in
                    switch style {
                    case .bar:
                        BarMark(
                            x: .value("Day", reading.day, unit: .day),
                            y: .value("Minutes", reading.value)
                        )
                        .foregroundStyle(by: .value("Activity", reading.category))
                    case .line:
                        LineMark(
                            x: .value("Day", reading.day, unit: .day),
                            y: .value("Minutes", reading.value)
                        )
                        .foregroundStyle(by: .value("Activity", reading.category))
                        .interpolationMethod(.catmullRom)
                        .symbol(by: .value("Activity", reading.category))
                    case .area:
                        AreaMark(
                            x: .value("Day", reading.day, unit: .day),
                            y: .value("Minutes", reading.value)
                        )
                        .foregroundStyle(by: .value("Activity", reading.category))
                        .opacity(0.7)
                    }
                }
                .chartXSelection(value: $selectedDay)
                .chartLegend(position: .bottom)
                .chartYAxisLabel("minutes")
                .frame(height: 240)

                if let selectedDay {
                    let matches = readings.filter { Calendar.current.isDate($0.day, inSameDayAs: selectedDay) }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedDay, format: .dateTime.weekday(.wide).month().day())
                            .font(.subheadline.bold())
                        ForEach(matches) { match in
                            Text("\(match.category): \(Int(match.value)) min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Touch and hold the chart to inspect a day.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }

        DemoCard("Totals", caption: "Plain Swift over the same array — charts don't own your data.") {
            HStack(spacing: 24) {
                ForEach(["Walking", "Cycling"], id: \.self) { category in
                    VStack(alignment: .leading) {
                        Text(category).font(.caption).foregroundStyle(.secondary)
                        Text("\(Int(SampleSeries.total(readings, category: category))) min")
                            .font(.title3.bold().monospacedDigit())
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView { VStack { ChartsDemo() }.padding() }
}
