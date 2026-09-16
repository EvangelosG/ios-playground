import Foundation
import Testing
@testable import iOSPlayground

struct PlaygroundFormattersTests {
    @Test func currencyFollowsTheLocale() {
        let us = PlaygroundFormatters.currency(1234.5, locale: Locale(identifier: "en_US"))
        let de = PlaygroundFormatters.currency(1234.5, locale: Locale(identifier: "de_DE"))
        #expect(us.contains("$"))
        #expect(us.contains("1,234"))
        #expect(de.contains("€"))
        #expect(de.contains("1.234"))
    }

    @Test func listsUseTheLocaleConjunction() {
        #expect(PlaygroundFormatters.list(["a", "b", "c"], locale: Locale(identifier: "en_US")).contains("and"))
        #expect(PlaygroundFormatters.list(["a", "b", "c"], locale: Locale(identifier: "de_DE")).contains("und"))
    }

    @Test func measurementsUseTheLocaleUnitSystem() {
        let metric = PlaygroundFormatters.measurement(4_200, locale: Locale(identifier: "de_DE"))
        let imperial = PlaygroundFormatters.measurement(4_200, locale: Locale(identifier: "en_US"))
        #expect(metric.contains("km"))
        #expect(imperial.contains("mi"))
    }
}

struct SampleSeriesTests {
    @Test func producesTwoSeriesPerDayInChronologicalOrder() {
        let readings = SampleSeries.readings(days: 7)
        #expect(readings.count == 14)
        #expect(Set(readings.map(\.category)) == ["Walking", "Cycling"])
        #expect(readings == readings.sorted { $0.day < $1.day })
    }

    @Test func totalSumsOnlyTheRequestedCategory() {
        let readings = SampleSeries.readings(days: 3)
        let walking = readings.filter { $0.category == "Walking" }
        #expect(SampleSeries.total(readings, category: "Walking") == walking.reduce(0) { $0 + $1.value })
        #expect(SampleSeries.total(readings, category: "Swimming") == 0)
    }
}
