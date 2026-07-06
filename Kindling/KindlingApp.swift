import SwiftUI

@main
struct KindlingApp: App {
    @StateObject private var store = KindlingStore()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
        }
    }
}
