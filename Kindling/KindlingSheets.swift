import SwiftUI

/// One unified sheet enum for the whole app — a single `.sheet(item:)` per
/// screen, per the standing rule.
enum KindlingSheet: Identifiable {
    case add
    case edit(GoodThingsEntry)
    case paywall

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let e): return "edit-\(e.id)"
        case .paywall: return "paywall"
        }
    }
}

struct EntryFormView: View {
    @EnvironmentObject private var store: KindlingStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let existing: GoodThingsEntry?

    @State private var date: Date
    @State private var thingOne: String
    @State private var thingTwo: String
    @State private var thingThree: String

    init(existing: GoodThingsEntry?) {
        self.existing = existing
        _date = State(initialValue: existing?.date ?? Date())
        _thingOne = State(initialValue: existing?.thingOne ?? "")
        _thingTwo = State(initialValue: existing?.thingTwo ?? "")
        _thingThree = State(initialValue: existing?.thingThree ?? "")
    }

    private var isEditing: Bool { existing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Night") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("dateField")
                }

                Section("Three Good Things") {
                    KindlingTextField(placeholder: "1. Something good today...", text: $thingOne)
                        .accessibilityIdentifier("thingOneField")
                    KindlingTextField(placeholder: "2. Something else good...", text: $thingTwo)
                        .accessibilityIdentifier("thingTwoField")
                    KindlingTextField(placeholder: "3. One more good thing...", text: $thingThree)
                        .accessibilityIdentifier("thingThreeField")
                }

                if isEditing {
                    Section {
                        Button("Delete Entry", role: .destructive) {
                            if let existing {
                                store.deleteEntry(existing.id)
                            }
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("deleteEntryButton")
                    }
                }
            }
            .dismissKeyboardOnTap()
            .navigationTitle(isEditing ? "Edit Night" : "Tonight's Good Things")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .accessibilityIdentifier("saveEntryButton")
                }
            }
        }
    }

    private func save() {
        if let existing {
            store.updateEntry(existing.id, date: date, thingOne: thingOne, thingTwo: thingTwo, thingThree: thingThree)
            dismiss()
        } else {
            guard store.canAddEntry(isPro: purchases.isPro) else { return }
            store.addEntry(date: date, thingOne: thingOne, thingTwo: thingTwo, thingThree: thingThree, isPro: purchases.isPro)
            dismiss()
        }
    }
}

private struct KindlingTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(1...3)
    }
}
