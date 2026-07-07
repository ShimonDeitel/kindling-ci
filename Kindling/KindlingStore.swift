import Foundation

@MainActor
final class KindlingStore: ObservableObject {
    @Published private(set) var entries: [GoodThingsEntry] = []

    private let freeLimit = 7
    private let fileURL: URL

    init(fileName: String = "kindling_entries.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent(fileName)
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
        }
        load()
    }

    var sortedEntries: [GoodThingsEntry] {
        entries.sorted { $0.date > $1.date }
    }

    func canAddEntry(isPro: Bool) -> Bool {
        isPro || entries.count < freeLimit
    }

    @discardableResult
    func addEntry(date: Date, thingOne: String, thingTwo: String, thingThree: String, isPro: Bool) -> Bool {
        guard canAddEntry(isPro: isPro) else { return false }
        let entry = GoodThingsEntry(date: date, thingOne: thingOne, thingTwo: thingTwo, thingThree: thingThree)
        entries.append(entry)
        save()
        return true
    }

    func updateEntry(_ id: UUID, date: Date, thingOne: String, thingTwo: String, thingThree: String) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[idx].date = date
        entries[idx].thingOne = thingOne
        entries[idx].thingTwo = thingTwo
        entries[idx].thingThree = thingThree
        save()
    }

    func deleteEntry(_ id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        entries.removeAll()
        save()
    }

    /// The signature "kindling" streak feature: consecutive calendar days
    /// (ending today or yesterday) with at least one complete entry — the
    /// literal flame that keeps burning as long as the streak continues.
    var currentStreak: Int {
        let calendar = Calendar.current
        let completeDays = Set(entries.filter { $0.isComplete }.map { calendar.startOfDay(for: $0.date) })
        guard !completeDays.isEmpty else { return 0 }

        var streak = 0
        var cursor = calendar.startOfDay(for: Date())
        if !completeDays.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        while completeDays.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return streak
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([GoodThingsEntry].self, from: data) {
            entries = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
