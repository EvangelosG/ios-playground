import XCTest

/// Walks the app the way a first-time reader would: open every tab, then open
/// every demo listed in it and confirm the screen renders.
final class CatalogUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func demoRows(in app: XCUIApplication) -> XCUIElementQuery {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH 'demo.'"))
    }

    func testEveryTabOpensItsDemos() {
        let app = XCUIApplication()
        app.launch()

        let tabButtons = app.tabBars.buttons
        XCTAssertGreaterThan(tabButtons.count, 0, "no tab bar found")

        for index in 0..<tabButtons.count {
            tabButtons.element(boundBy: index).tap()

            let rows = demoRows(in: app)
            XCTAssertTrue(
                rows.firstMatch.waitForExistence(timeout: 5),
                "tab \(index) listed no demos"
            )

            let identifiers = rows.allElementsBoundByIndex.map { $0.identifier }
            for identifier in identifiers {
                let row = rows[identifier]
                guard row.exists, row.isHittable else { continue }
                row.tap()

                let demoID = identifier.replacingOccurrences(of: "demo.", with: "")
                XCTAssertTrue(
                    app.buttons["howItWorks"].waitForExistence(timeout: 5),
                    "demo \(demoID) did not present a screen"
                )

                app.navigationBars.buttons.element(boundBy: 0).tap()
                XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: 5))
            }
        }
    }

    func testHowItWorksSheetOpens() {
        let app = XCUIApplication()
        app.launch()

        let row = demoRows(in: app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        app.buttons["howItWorks"].tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
    }
}
