import SwiftUI

@main
struct HumorMeApp: App {
    @StateObject private var store: AppStore
    init() {
        _store = StateObject(wrappedValue: AppStore())
    }
    var body: some Scene {
        WindowGroup {
            mainContent
        }
    }
    private var mainContent: some View {
            TabView {
                NavigationStack { ShowsView() }
                    .tabItem { Label("Search Shows", systemImage: "magnifyingglass") }
                NavigationStack { ComediansView() }
                    .tabItem { Label("Find Comedians", systemImage: "person.2") }
            }
            .tint(ComedyPalette.sage)
            .preferredColorScheme(.dark)
            .environmentObject(store)
            .task { await store.loadCatalog() }
    }
}
