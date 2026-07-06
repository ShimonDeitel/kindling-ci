import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var store: KindlingStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("kindling_nightly_reminder") private var nightlyReminder: Bool = false
    @State private var activeSheet: KindlingSheet?
    @State private var showResetConfirm = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    Toggle("Nightly reminder at 9:30 PM", isOn: $nightlyReminder)
                        .accessibilityIdentifier("nightlyReminderToggle")
                        .onChange(of: nightlyReminder) { _, newValue in
                            KindlingReminderScheduler.setNightlyReminder(enabled: newValue)
                        }
                }

                Section("Kindling Pro") {
                    if purchases.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(KDTheme.coral)
                    } else {
                        Button("Upgrade to Pro") {
                            activeSheet = .paywall
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("upgradeProButton")
                    }
                    Button("Restore Purchases") {
                        Task {
                            await purchases.restore()
                            restoreMessage = purchases.isPro ? "Purchases restored." : "No purchases found."
                        }
                    }
                    .buttonStyle(.plain)
                    if let restoreMessage {
                        Text(restoreMessage)
                            .font(.caption)
                            .foregroundStyle(KDTheme.inkFaded)
                    }
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/kindling-site/privacy.html")!)
                    Link("Contact Support", destination: URL(string: "mailto:s0533495227@gmail.com")!)
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(KDTheme.inkFaded)
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        showResetConfirm = true
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset all logged nights?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .paywall:
                    PaywallView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

enum KindlingReminderScheduler {
    static func setNightlyReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        let identifier = "kindling_nightly_reminder"
        if enabled {
            center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                guard granted else { return }
                let content = UNMutableNotificationContent()
                content.title = "Kindling"
                content.body = "What were three good things today? Keep your streak alive."
                content.sound = .default
                var comps = DateComponents()
                comps.hour = 21
                comps.minute = 30
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                center.add(request)
            }
        } else {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(KindlingStore())
        .environmentObject(PurchaseManager())
}
