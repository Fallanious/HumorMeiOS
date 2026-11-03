import SwiftUI

struct ComediansView: View {
    @EnvironmentObject private var store: AppStore
    @State private var search = ""
    @State private var headerHeight: CGFloat = 0

    private var results: [Comedian] {
        store.comedians.filter { search.isEmpty || $0.comedian.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        GeometryReader { viewport in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                        .background {
                            GeometryReader { geometry in
                                Color.clear.preference(key: ComedianHeaderHeightKey.self, value: geometry.size.height)
                            }
                        }
                    if store.loadingCatalog {
                        ProgressView("Loading comedians…")
                            .tint(ComedyPalette.blush)
                            .frame(maxWidth: .infinity)
                            .frame(height: max(80, viewport.size.height - headerHeight - 60))
                    } else if store.catalogError != nil {
                        MessageView(title: "Unable to load comedians", message: "We couldn’t load the comedians right now. Please try again.") {
                            Task { await store.loadCatalog() }
                        }
                    } else if results.isEmpty {
                        MessageView(title: "No comedians found", message: "Try a different name.")
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, comedian in
                                NavigationLink { ComedianDetailsView(comedian: comedian) } label: {
                                    HStack(spacing: 16) {
                                        Portrait(source: comedian.profile_image)
                                        VStack(alignment: .leading, spacing: 7) {
                                            Text(comedian.comedian)
                                                .font(.custom("Archivo-Bold", size: 21, relativeTo: .title3)).tracking(-0.5)
                                            Text("Explore shows")
                                                .font(.custom("Archivo-Regular", size: 11, relativeTo: .caption))
                                        }
                                        Spacer(minLength: 0)
                                    }
                                    .padding(18)
                                    .foregroundStyle(ComedyPalette.background)
                                    .background(index % 2 == 0 ? ComedyPalette.sage : ComedyPalette.blush, in: RoundedRectangle(cornerRadius: 14))
                                    .multilineTextAlignment(.leading)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }.padding(.horizontal, 24).padding(.vertical, 20)
                    .onPreferenceChange(ComedianHeaderHeightKey.self) { headerHeight = $0 }
            }
        }
        .background(ComedyPalette.background.ignoresSafeArea())
        .foregroundStyle(ComedyPalette.blush)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(ComedyPalette.ink, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .scrollDismissesKeyboard(.interactively)
        .refreshable { await store.loadCatalog() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Find")
                Text("comedians.")
            }.font(.custom("Archivo-Black", size: 43, relativeTo: .largeTitle)).tracking(-1.8)
            ComedySearchField(text: $search, placeholder: "Comedian name", accessibilityLabel: "Search comedians by name")
            HStack {
                Text("FIND YOUR FAVORITES")
                    .font(.custom("Archivo-Bold", size: 10, relativeTo: .caption)).tracking(1.6)
                Spacer()
                Text("\(results.count) comedians").font(.caption).foregroundStyle(ComedyPalette.muted)
            }
        }
    }
}

private struct ComedianHeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct ComedianDetailsView: View {
    let comedian: Comedian
    var body: some View {
        ShowsView(comedian: comedian.comedian, comedianImage: comedian.profile_image)
    }
}
