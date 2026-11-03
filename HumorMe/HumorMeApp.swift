import SwiftUI

@main
struct HumorMeApp: App {
    @StateObject private var store: AppStore
    @State private var mockupsClosed = false
    init() {
        _store = StateObject(wrappedValue: AppStore())
    }
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if CommandLine.arguments.contains("-comedian-mockups") && !mockupsClosed {
                ComedianHomeMockups(initialConcept: comedianMockupConcept, onClose: { mockupsClosed = true })
            } else if CommandLine.arguments.contains("-show-mockups") && !mockupsClosed {
                ShowMockupGallery(initialConcept: mockupConcept, onClose: { mockupsClosed = true })
            } else {
                mainContent
            }
            #else
            mainContent
            #endif
        }
    }
    private var comedianMockupConcept: Int {
        guard let index = CommandLine.arguments.firstIndex(of: "-comedian-mockups"),
              CommandLine.arguments.indices.contains(index + 1) else { return 0 }
        return Int(CommandLine.arguments[index + 1]) ?? 0
    }
    private var mockupConcept: Int {
        guard let index = CommandLine.arguments.firstIndex(of: "-show-mockups"),
              CommandLine.arguments.indices.contains(index + 1) else { return 0 }
        return Int(CommandLine.arguments[index + 1]) ?? 0
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
