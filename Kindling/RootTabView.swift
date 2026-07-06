import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            KindlingHomeView()
                .tabItem {
                    Label("Log", systemImage: "flame.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(KDTheme.lavenderDeep)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(KDTheme.surface)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(KindlingStore())
        .environmentObject(PurchaseManager())
}
