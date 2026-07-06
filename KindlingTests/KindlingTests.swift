import XCTest
@testable import Kindling

@MainActor
final class KindlingTests: XCTestCase {
    private func makeStore() -> KindlingStore {
        let name = "test_kindling_\(UUID().uuidString).json"
        return KindlingStore(fileName: name)
    }

    func testAddEntry() {
        let store = makeStore()
        let added = store.addEntry(date: Date(), thingOne: "Sunshine", thingTwo: "Coffee", thingThree: "Nap", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.thingOne, "Sunshine")
    }

    func testFreeLimitBlocksAtSeven() {
        let store = makeStore()
        for i in 0..<7 {
            let added = store.addEntry(date: Date(), thingOne: "\(i)a", thingTwo: "\(i)b", thingThree: "\(i)c", isPro: false)
            XCTAssertTrue(added)
        }
        XCTAssertFalse(store.canAddEntry(isPro: false))
        let eighth = store.addEntry(date: Date(), thingOne: "x", thingTwo: "y", thingThree: "z", isPro: false)
        XCTAssertFalse(eighth)
        XCTAssertEqual(store.entries.count, 7)
    }

    func testProBypassesFreeLimit() {
        let store = makeStore()
        for i in 0..<7 {
            _ = store.addEntry(date: Date(), thingOne: "\(i)a", thingTwo: "\(i)b", thingThree: "\(i)c", isPro: true)
        }
        let added = store.addEntry(date: Date(), thingOne: "x", thingTwo: "y", thingThree: "z", isPro: true)
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, 8)
    }

    func testUpdateEntry() {
        let store = makeStore()
        _ = store.addEntry(date: Date(), thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)
        guard let id = store.entries.first?.id else { return XCTFail("no entry") }
        store.updateEntry(id, date: Date(), thingOne: "x", thingTwo: "y", thingThree: "z")
        XCTAssertEqual(store.entries.first?.thingOne, "x")
    }

    func testDeleteEntry() {
        let store = makeStore()
        _ = store.addEntry(date: Date(), thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)
        guard let id = store.entries.first?.id else { return XCTFail("no entry") }
        store.deleteEntry(id)
        XCTAssertTrue(store.entries.isEmpty)
    }

    func testDeleteAllData() {
        let store = makeStore()
        _ = store.addEntry(date: Date(), thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)
        store.deleteAllData()
        XCTAssertTrue(store.entries.isEmpty)
    }

    func testFilledCountAndIsComplete() {
        let full = GoodThingsEntry(thingOne: "a", thingTwo: "b", thingThree: "c")
        XCTAssertEqual(full.filledCount, 3)
        XCTAssertTrue(full.isComplete)

        let partial = GoodThingsEntry(thingOne: "a", thingTwo: "", thingThree: "")
        XCTAssertEqual(partial.filledCount, 1)
        XCTAssertFalse(partial.isComplete)
    }

    func testStreakZeroWhenNoEntries() {
        let store = makeStore()
        XCTAssertEqual(store.currentStreak, 0)
    }

    func testStreakCountsConsecutiveCompleteDays() {
        let store = makeStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        _ = store.addEntry(date: today, thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)
        _ = store.addEntry(date: yesterday, thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)
        _ = store.addEntry(date: twoDaysAgo, thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)

        XCTAssertEqual(store.currentStreak, 3)
    }

    func testStreakBreaksOnIncompleteEntry() {
        let store = makeStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        _ = store.addEntry(date: today, thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)
        // yesterday's entry is incomplete (only 1 of 3 filled) — should not count toward streak
        _ = store.addEntry(date: yesterday, thingOne: "a", thingTwo: "", thingThree: "", isPro: false)

        XCTAssertEqual(store.currentStreak, 1)
    }

    func testStreakResetsIfGapDay() {
        let store = makeStore()
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
        _ = store.addEntry(date: threeDaysAgo, thingOne: "a", thingTwo: "b", thingThree: "c", isPro: false)
        XCTAssertEqual(store.currentStreak, 0)
    }

    func testSortedEntriesNewestFirst() {
        let store = makeStore()
        let earlier = Date().addingTimeInterval(-86400)
        let later = Date()
        _ = store.addEntry(date: earlier, thingOne: "old", thingTwo: "b", thingThree: "c", isPro: false)
        _ = store.addEntry(date: later, thingOne: "new", thingTwo: "b", thingThree: "c", isPro: false)
        XCTAssertEqual(store.sortedEntries.first?.thingOne, "new")
    }

    func testPersistenceRoundTrip() {
        let fileName = "test_persist_\(UUID().uuidString).json"
        let store1 = KindlingStore(fileName: fileName)
        _ = store1.addEntry(date: Date(), thingOne: "persisted", thingTwo: "b", thingThree: "c", isPro: false)
        let store2 = KindlingStore(fileName: fileName)
        XCTAssertEqual(store2.entries.count, 1)
        XCTAssertEqual(store2.entries.first?.thingOne, "persisted")
    }
}
