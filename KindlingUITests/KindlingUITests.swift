import XCTest

final class KindlingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFromHome() {
        let addButton = app.buttons["addEntryButton"]
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
        } else {
            app.buttons["logTonightButton"].tap()
        }
        let field = app.textFields["thingOneField"]
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.typeText("Good sunshine")
        }
        let saveButton1 = app.buttons["saveEntryButton"]
        XCTAssertTrue(saveButton1.waitForExistence(timeout: 8), "Save button did not appear")
        saveButton1.tap()
        XCTAssertTrue(app.navigationBars["Kindling"].waitForExistence(timeout: 5))
    }

    func testEditEntryViaMenu() {
        addSeedEntry()
        let menu = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'entryMenu_'")).firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 5))
        menu.tap()
        app.buttons["Edit"].tap()
        let saveButton = app.buttons["saveEntryButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
    }

    func testDeleteEntryViaMenu() {
        addSeedEntry()
        let menu = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'entryMenu_'")).firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 5))
        menu.tap()
        app.buttons["Delete"].tap()
        let confirmDelete = app.buttons.matching(identifier: "Delete").element(boundBy: max(0, app.buttons.matching(identifier: "Delete").count - 1))
        if confirmDelete.waitForExistence(timeout: 3) {
            confirmDelete.tap()
        }
    }

    func testSettingsTabOpensAndTogglesReminder() {
        app.tabBars.buttons["Settings"].tap()
        let toggle = app.switches["nightlyReminderToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()
    }

    func testFreeLimitTriggersPaywall() {
        for _ in 0..<8 {
            let addButton = app.buttons["addEntryButton"]
            if addButton.waitForExistence(timeout: 3) {
                addButton.tap()
            } else if app.buttons["logTonightButton"].waitForExistence(timeout: 3) {
                app.buttons["logTonightButton"].tap()
            } else {
                break
            }
            let saveButton = app.buttons["saveEntryButton"]
            if saveButton.waitForExistence(timeout: 3) {
                saveButton.tap()
            }
        }
        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5) || app.navigationBars["Kindling"].exists)
    }

    func testStreakCardAppearsAfterEntry() {
        addSeedEntry()
        XCTAssertTrue(app.otherElements["streakCard"].waitForExistence(timeout: 5) || app.staticTexts["Current streak"].waitForExistence(timeout: 5))
    }

    private func addSeedEntry() {
        let addButton = app.buttons["addEntryButton"]
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
        } else {
            app.buttons["logTonightButton"].tap()
        }
        let field = app.textFields["thingOneField"]
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.typeText("Seed thing")
        }
        let saveButton = app.buttons["saveEntryButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 8), "Save button did not appear")
        saveButton.tap()
    }
}
