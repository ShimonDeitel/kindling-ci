import SwiftUI

struct KindlingHomeView: View {
    @EnvironmentObject private var store: KindlingStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var activeSheet: KindlingSheet?

    var body: some View {
        NavigationStack {
            ZStack {
                KDTheme.backdrop.ignoresSafeArea()

                if store.entries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            streakCard
                                .padding(.top, 8)

                            ForEach(store.sortedEntries) { entry in
                                EntryRow(entry: entry) {
                                    activeSheet = .edit(entry)
                                } onDelete: {
                                    store.deleteEntry(entry.id)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Kindling")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddEntry(isPro: purchases.isPro) {
                            activeSheet = .add
                        } else {
                            activeSheet = .paywall
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    EntryFormView(existing: nil)
                case .edit(let entry):
                    EntryFormView(existing: entry)
                case .paywall:
                    PaywallView()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            KindlingFlame(streak: 0)
                .frame(width: 90, height: 110)
            Text("What went well today?")
                .font(KDTheme.headlineFont)
                .foregroundStyle(KDTheme.ink)
            Text("Write down three good things each night — a proven CBT gratitude practice.")
                .font(.subheadline)
                .foregroundStyle(KDTheme.inkFaded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Log Tonight") {
                activeSheet = .add
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(KDTheme.lavenderDeep)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .accessibilityIdentifier("logTonightButton")
        }
    }

    private var streakCard: some View {
        HStack(spacing: 20) {
            KindlingFlame(streak: store.currentStreak)
                .frame(width: 64, height: 78)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(store.currentStreak) night\(store.currentStreak == 1 ? "" : "s")")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(KDTheme.ink)
                Text("Current streak")
                    .font(.caption)
                    .foregroundStyle(KDTheme.inkFaded)
            }
            Spacer()
        }
        .padding(16)
        .background(KDTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier("streakCard")
    }
}

/// The quirky signature feature: a literal flame that grows taller and
/// brighter (violet ember -> bright coral-gold) the longer the current
/// nightly streak runs — echoed in the app icon.
struct KindlingFlame: View {
    let streak: Int

    private var heightRatio: CGFloat {
        min(1.0, 0.35 + CGFloat(streak) * 0.05)
    }

    private var flameColor: Color {
        let t = min(1.0, Double(streak) / 14.0)
        return Color(
            red: KDTheme.lavender.components.r + (KDTheme.coralGlow.components.r - KDTheme.lavender.components.r) * t,
            green: KDTheme.lavender.components.g + (KDTheme.coralGlow.components.g - KDTheme.lavender.components.g) * t,
            blue: KDTheme.lavender.components.b + (KDTheme.coralGlow.components.b - KDTheme.lavender.components.b) * t
        )
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer(minLength: 0)
                Image(systemName: "flame.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: geo.size.height * heightRatio)
                    .foregroundStyle(flameColor)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: streak)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
    }
}

private extension Color {
    var components: (r: Double, g: Double, b: Double) {
        let resolved = self.resolve(in: EnvironmentValues())
        return (Double(resolved.red), Double(resolved.green), Double(resolved.blue))
    }
}

struct EntryRow: View {
    let entry: GoodThingsEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(Self.dateFormatter.string(from: entry.date))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KDTheme.ink)
                Spacer()
                Menu {
                    Button("Edit", action: onEdit)
                    Button("Delete", role: .destructive) { showDeleteConfirm = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(KDTheme.lavender)
                        .frame(width: 32, height: 32)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityIdentifier("entryMenu_\(entry.id)")
                .accessibilityAddTraits(.isButton)
                .contentShape(Rectangle())
            }
            ForEach([entry.thingOne, entry.thingTwo, entry.thingThree].filter { !$0.isEmpty }, id: \.self) { thing in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.caption2)
                        .foregroundStyle(KDTheme.coral)
                        .padding(.top, 3)
                    Text(thing)
                        .font(.subheadline)
                        .foregroundStyle(KDTheme.inkFaded)
                }
            }
        }
        .padding(14)
        .background(KDTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .confirmationDialog("Delete this night's entry?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        }
    }
}
