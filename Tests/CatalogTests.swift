import Testing
@testable import iOSPlayground

@MainActor
struct CatalogTests {
    @Test func everyDemoIdentifierIsUnique() {
        let ids = DemoCatalog.allDemos.map(\.id.rawValue)
        #expect(Set(ids).count == ids.count)
    }

    @Test func everyTabHasAtLeastOneDemo() {
        for tab in DemoCatalog.tabs {
            #expect(!tab.demos.isEmpty, "\(tab.title) has no demos")
        }
    }

    @Test func demoLookupFindsEveryDemo() {
        for demo in DemoCatalog.allDemos {
            #expect(DemoCatalog.demo(id: demo.id) != nil)
        }
    }

    @Test func everyDemoIsDocumented() {
        for demo in DemoCatalog.allDemos {
            #expect(!demo.summary.isEmpty, "\(demo.id.rawValue) has no summary")
            #expect(!demo.notes.explanation.isEmpty, "\(demo.id.rawValue) has no explanation")
            #expect(!demo.notes.code.isEmpty, "\(demo.id.rawValue) has no code sample")
        }
    }

    @Test func searchMatchesTitleAndSummary() {
        #expect(!DemoCatalog.search("glass").isEmpty)
        #expect(DemoCatalog.search("   ").isEmpty)
        #expect(DemoCatalog.search("zzzzz-nothing").isEmpty)
    }
}
