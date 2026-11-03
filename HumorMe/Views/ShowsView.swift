import SwiftUI

struct ShowsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var filter = ShowFilter()
    @State private var shows: [Show] = []
    @State private var search = ""
    @State private var byPrice = false
    @State private var loading = true
    @State private var headerHeight: CGFloat = 0
    @State private var error: String?
    @State private var filtersPresented = false
    @State private var requestID = UUID()
    @State private var mockupsPresented = false
    @State private var comedianMockupsPresented = false
    var comedian: String? = nil
    var comedianImage: String? = nil

    private var results: [Show] {
        let matching = shows.filter {
            search.isEmpty || ([$0.title, $0.venue] + $0.comics).contains { $0.localizedCaseInsensitiveContains(search) }
        }
        return byPrice ? matching.sorted { ($0.price ?? .infinity) < ($1.price ?? .infinity) } : matching.sorted { ($0.date, $0.minutesAfterMidnight, $0.id) < ($1.date, $1.minutesAfterMidnight, $1.id) }
    }
    private var path: [String] { comedian.map { ["shows", "comic", $0] } ?? filter.path }
    var body: some View {
        GeometryReader { viewport in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerContent
                        .background {
                            GeometryReader { header in
                                Color.clear.preference(key: ShowHeaderHeightKey.self, value: header.size.height)
                            }
                        }
                    if loading {
                        ProgressView("Loading shows…")
                            .tint(ComedyPalette.blush)
                            .frame(maxWidth: .infinity)
                            .frame(height: max(80, viewport.size.height - headerHeight - 60))
                    } else {
                        showList
                    }
                }
                .padding(.horizontal, 24).padding(.vertical, 20)
                .onPreferenceChange(ShowHeaderHeightKey.self) { headerHeight = $0 }
            }
        }
        .background(ComedyPalette.background.ignoresSafeArea())
        .foregroundStyle(ComedyPalette.blush)
        .navigationTitle("")
        .toolbar(comedian == nil ? .hidden : .visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ComedyPalette.ink, for: .navigationBar, .tabBar)
        .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $filtersPresented) { FilterView(filter: $filter) }
        .fullScreenCover(isPresented: $mockupsPresented) { ShowMockupGallery() }
        .fullScreenCover(isPresented: $comedianMockupsPresented) {
            ComedianHomeMockups(name: comedian ?? "Sam Morril", portrait: comedianImage)
        }
        .task(id: path) { await load() }
        .refreshable { await load() }
    }
    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 20) {
                if comedian == nil {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Find").foregroundStyle(ComedyPalette.blush)
                        Text("comedy.").foregroundStyle(ComedyPalette.blush)
                    }.font(.custom("Archivo-Black", size: 43, relativeTo: .largeTitle)).tracking(-1.8)
                } else if let comedian {
                    ComedianCompactHeader(name: comedian, portrait: comedianImage)
                }
                if comedian == nil {
                    searchBar
                    quickDates
                }
                HStack {
                    Text(comedian == nil ? "ON AROUND YOU" : "UPCOMING SHOWS")
                        .font(.custom("Archivo-Bold", size: 10, relativeTo: .caption)).tracking(1.6)
                    Spacer()
                    Menu {
                        Toggle("Sort by price", isOn: $byPrice)
                        #if DEBUG
                        if comedian != nil {
                            Button("Comedian Mockups", systemImage: "rectangle.3.group") { comedianMockupsPresented = true }
                        } else {
                            Button("UI Mockups", systemImage: "rectangle.3.group") { mockupsPresented = true }
                        }
                        #endif
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(results.count) shows")
                            Image(systemName: "arrow.up.arrow.down")
                        }.font(.caption).foregroundStyle(ComedyPalette.muted)
                    }.accessibilityLabel("List options, \(results.count) shows")
                }.foregroundStyle(ComedyPalette.blush)
        }
    }
    private var showList: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
                if error != nil {
                    MessageView(title: "Unable to load shows", message: "We couldn’t load the shows right now. Please try again.") {
                        Task { await load() }
                    }
                }
                if error == nil && results.isEmpty {
                    MessageView(title: "No shows found", message: comedian == nil ? "Try another date, city, or comedian." : search.isEmpty ? "No shows are currently listed for this comedian. Check back soon." : "Try a different search for this comedian’s shows.")
                }
                ForEach(Array(results.enumerated()), id: \.element.id) { index, show in
                    NavigationLink { ShowDetailsView(show: show) } label: {
                        if comedian != nil {
                            ComedianShowRow(show: show, alternate: index % 2 == 1)
                        } else {
                            ShowRow(show: show, alternate: index % 2 == 1)
                        }
                    }.buttonStyle(.plain)
                }
        }
    }
    private var searchBar: some View {
        ComedySearchField(text: $search, placeholder: "Title, venue, or comedian", accessibilityLabel: "Search shows by title, venue, or comedian")
    }
    private var quickDates: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
                    let selected = index == 2 ? !filter.datesEnabled : filter.datesEnabled && Calendar.current.isDate(filter.startDate, inSameDayAs: date) && Calendar.current.isDate(filter.endDate, inSameDayAs: date)
                    Button {
                        filter.datesEnabled = index != 2
                        if index != 2 { filter.startDate = date; filter.endDate = date }
                    } label: {
                        Text(["Today", "Tomorrow", "All dates"][index])
                            .font(.custom("Archivo-Bold", size: 12, relativeTo: .subheadline))
                            .padding(.horizontal, 12).padding(.vertical, 12)
                            .foregroundStyle(selected ? ComedyPalette.background : ComedyPalette.blush)
                            .background(selected ? ComedyPalette.sage : .clear, in: Capsule())
                            .overlay(Capsule().stroke(ComedyPalette.muted.opacity(selected ? 0 : 0.35)))
                    }.accessibilityAddTraits(selected ? .isSelected : [])
                }
                Button { filtersPresented = true } label: {
                    Label("Filters", systemImage: "slider.horizontal.3")
                        .font(.custom("Archivo-Bold", size: 12, relativeTo: .subheadline))
                        .padding(.horizontal, 12).padding(.vertical, 12)
                        .foregroundStyle(ComedyPalette.blush)
                        .background(ComedyPalette.blush.opacity(0.08), in: Capsule())
                        .overlay(Capsule().stroke(ComedyPalette.muted.opacity(0.35)))
                }.accessibilityLabel("Show filters")
            }
        }
    }
    @MainActor private func load() async {
        let request = UUID()
        requestID = request
        loading = true
        error = nil
        defer { if requestID == request { loading = false } }
        do {
            let loaded: [Show] = try await store.client().get(path)
            try Task.checkCancellation()
            guard requestID == request else { return }
            shows = loaded
        } catch is CancellationError { }
        catch let failure as URLError where failure.code == .cancelled { }
        catch {
            guard requestID == request else { return }
            self.error = error.localizedDescription; shows = []
        }
    }
}

private struct ShowHeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct FilterView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: ShowFilter
    @State private var draft: ShowFilter
    init(filter: Binding<ShowFilter>) {
        _filter = filter
        _draft = State(initialValue: filter.wrappedValue)
    }
    var body: some View {
        NavigationStack {
            Form {
                if store.catalogError != nil {
                    Section {
                        MessageView(title: "Unable to load filters", message: "We couldn’t load cities and comedians right now. Please try again.") {
                            Task { await store.loadCatalog() }
                        }
                    }
                }
                Section("Where and who") {
                    NavigationLink("Cities (\(draft.cities.count))") {
                        MultipleSelection(title: "Cities", options: store.cities, selection: $draft.cities)
                    }
                    NavigationLink("Comedians (\(draft.comedians.count))") {
                        MultipleSelection(title: "Comedians", options: store.comedians.map(\.comedian), selection: $draft.comedians)
                    }
                }
                Section("When") {
                    Toggle("Choose dates", isOn: $draft.datesEnabled)
                    if draft.datesEnabled {
                        DatePicker("From", selection: $draft.startDate, displayedComponents: .date)
                            .onChange(of: draft.startDate) { value in
                                if draft.endDate < value { draft.endDate = value }
                            }
                        DatePicker("Through", selection: $draft.endDate, in: draft.startDate..., displayedComponents: .date)
                    }
                    Button("Today") { draft.datesEnabled = true; draft.startDate = Date(); draft.endDate = Date() }
                    Button("This week") { selectDays(weekend: false) }
                    Button("This weekend") { selectDays(weekend: true) }
                }
                Section {
                    TextField("Maximum ticket price", text: $draft.maximumPrice).keyboardType(.decimalPad)
                } header: { Text("Price") } footer: { Text("Enter 0 for free shows. Leave blank for any price.") }
                Button("Clear All") { draft = ShowFilter() }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { filter = draft; dismiss() }
                        .disabled(!draft.maximumPrice.isEmpty && (Double(draft.maximumPrice).map { $0 >= 0 && $0.isFinite } != true))
                }
            }
        }
    }
    private func selectDays(weekend: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysToSunday = (8 - weekday) % 7
        draft.datesEnabled = true
        draft.endDate = calendar.date(byAdding: .day, value: daysToSunday, to: today) ?? today
        draft.startDate = weekend && weekday != 1 ? calendar.date(byAdding: .day, value: max(0, daysToSunday - 1), to: today) ?? today : today
    }
}

struct ShowDetailsView: View {
    @EnvironmentObject private var store: AppStore
    let show: Show

    private var address: String {
        show.address.isEmpty ? store.venues.first { $0.name == show.venue }?.address ?? "" : show.address
    }
    private var comedians: [String] { Array(Set(show.comics)).sorted() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(show.title)
                    .font(.custom("Archivo-Black", size: 34, relativeTo: .largeTitle)).tracking(-1)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: 16) {
                    Text(show.dateLabel)
                        .font(.custom("Archivo-Bold", size: 13, relativeTo: .subheadline))
                    if !show.time.isEmpty {
                        Text(show.time)
                            .font(.custom("Archivo-Black", size: 28, relativeTo: .title)).tracking(-0.6)
                    }
                    Rectangle().fill(ComedyPalette.background.opacity(0.18)).frame(height: 1)
                    Text(show.venue)
                        .font(.custom("Archivo-Bold", size: 22, relativeTo: .title2))
                    if !show.spot.isEmpty { Text(show.spot) }
                    if !address.isEmpty { Text(address) }
                    if !show.city.isEmpty { Text(show.city) }
                    PricePill(text: show.cost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "See price" : show.priceLabel)
                        .accessibilityLabel(show.priceLabel)
                    if !show.fee.isEmpty {
                        Text("Additional fee: \(show.fee)")
                            .font(.custom("Archivo-Regular", size: 12, relativeTo: .caption))
                    }
                }
                .font(.custom("Archivo-Regular", size: 14, relativeTo: .body))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .foregroundStyle(ComedyPalette.background)
                .background(ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 14))

                if let url = webURL(show.url) {
                    VStack(spacing: 12) {
                        Link(destination: url) {
                            Text("View event")
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .foregroundStyle(ComedyPalette.background)
                                .background(ComedyPalette.blush, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .font(.custom("Archivo-Bold", size: 14, relativeTo: .headline))
                    .buttonStyle(.plain)
                }

                Text("FEATURING")
                    .font(.custom("Archivo-Bold", size: 10, relativeTo: .caption)).tracking(1.6)
                    .accessibilityAddTraits(.isHeader)
                if comedians.isEmpty {
                    Text("We don’t know the lineup yet. Check the event page or come back closer to the show date.")
                        .font(.custom("Archivo-Regular", size: 14, relativeTo: .body))
                        .foregroundStyle(ComedyPalette.muted)
                }
                LazyVStack(spacing: 14) {
                    ForEach(Array(comedians.enumerated()), id: \.element) { index, name in
                        NavigationLink {
                            ComedianDetailsView(comedian: store.comedians.first { $0.comedian == name } ?? Comedian(comedian: name, profile_image: nil))
                        } label: {
                            HStack(spacing: 16) {
                                Portrait(source: store.comedians.first { $0.comedian == name }?.profile_image)
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(name)
                                        .font(.custom("Archivo-Bold", size: 21, relativeTo: .title3)).tracking(-0.5)
                                    Text("Explore shows")
                                        .font(.custom("Archivo-Regular", size: 11, relativeTo: .caption))
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(18).frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(ComedyPalette.background)
                            .background(index % 2 == 0 ? ComedyPalette.blush : ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 14))
                            .multilineTextAlignment(.leading)
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                        }.buttonStyle(.plain)
                    }
                }
                Text("Lineup may be subject to change.")
                    .font(.custom("Archivo-Regular", size: 12, relativeTo: .caption))
                    .foregroundStyle(ComedyPalette.muted)
            }
            .padding(.horizontal, 24).padding(.vertical, 20)
        }
        .background(ComedyPalette.background.ignoresSafeArea())
        .foregroundStyle(ComedyPalette.blush)
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            if let url = webURL(show.url) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: url, subject: Text(show.title), message: Text("\(show.title) at \(show.venue)")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundStyle(ComedyPalette.blush)
                    .accessibilityLabel("Share show")
                }
            }
        }
        .toolbarBackground(ComedyPalette.ink, for: .navigationBar, .tabBar)
        .toolbarBackground(.visible, for: .navigationBar, .tabBar)
    }
}
