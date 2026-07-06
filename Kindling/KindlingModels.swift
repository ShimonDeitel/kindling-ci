import Foundation

/// A single night's "three good things" CBT entry — the classic
/// positive-psychology exercise: write down three good things that
/// happened today, however small.
struct GoodThingsEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var thingOne: String
    var thingTwo: String
    var thingThree: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        thingOne: String = "",
        thingTwo: String = "",
        thingThree: String = "",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.thingOne = thingOne
        self.thingTwo = thingTwo
        self.thingThree = thingThree
        self.createdDate = createdDate
    }

    var filledCount: Int {
        [thingOne, thingTwo, thingThree]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
    }

    var isComplete: Bool { filledCount == 3 }
}
