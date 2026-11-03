import SwiftUI

private struct MockShow: Identifiable {
    let id: Int
    let title: String
    let venue: String
    let neighborhood: String
    let time: String
    let price: String
    let lineup: String
    static let samples = [
        MockShow(id: 1, title: "Good Eggs", venue: "New York Comedy Club", neighborhood: "East Village", time: "7:00", price: "$25", lineup: "Mark Normand · Emma Willmann\nGary Vider · Matt Ruby"),
        MockShow(id: 2, title: "The late set", venue: "Comedy Cellar", neighborhood: "Greenwich Village", time: "9:30", price: "$30", lineup: "Sam Morril · Jessica Kirson\nMatteo Lane · Surprise guests"),
        MockShow(id: 3, title: "Small room. Big laughs.", venue: "The Stand", neighborhood: "Union Square", time: "10:00", price: "$20", lineup: "Rachel Feinstein · Jordan Jensen\nDan Soder · Friends")
    ]
}

/// Isolated design gallery. All lineups, times and prices are illustrative, not live listings.
struct ShowMockupGallery: View {
    @Environment(\.dismiss) private var dismiss
    @State private var concept: Int
    @State private var selectedDate = 0
    @State private var saved: Set<Int> = []
    @State private var selectedShow: MockShow?
    private let onClose: (() -> Void)?
    private let names = ["01 / Marquee", "02 / Shows", "03 / Tonight"]
    init(initialConcept: Int = 0, onClose: (() -> Void)? = nil) {
        _concept = State(initialValue: min(2, max(0, initialConcept)))
        self.onClose = onClose
    }

    var body: some View {
        VStack(spacing: 0) {
            galleryControls
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    if concept == 0 { marquee }
                    else if concept == 1 { showCards }
                    else { tonight }
                }.padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 30)
            }.id(concept)
        }
        .background(ComedyPalette.background.ignoresSafeArea())
        .foregroundStyle(ComedyPalette.blush)
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedShow) { show in
            sampleDetail(show)
                .presentationDetents([.medium, .large])
        }
    }

    private var galleryControls: some View {
        VStack(spacing: 12) {
            HStack {
                Text("DESIGN STUDIES / SAMPLE CONTENT").font(.system(size: 9, weight: .semibold, design: .monospaced)).tracking(1)
                Spacer()
                Button { if let onClose { onClose() } else { dismiss() } } label: { Image(systemName: "xmark").font(.system(size: 11, weight: .bold)) }
                    .accessibilityLabel("Close mockups")
            }.foregroundStyle(ComedyPalette.muted)
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Button { concept = index; selectedDate = 0 } label: {
                        Text(names[index]).font(.system(size: 11, weight: .semibold))
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(concept == index ? ComedyPalette.blush : .clear, in: Capsule())
                            .foregroundStyle(concept == index ? ComedyPalette.background : ComedyPalette.muted)
                    }.accessibilityAddTraits(concept == index ? .isSelected : [])
                }
            }
        }.padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 14)
            .background(ComedyPalette.ink)
    }

    private var location: some View {
        HStack {
            Text("humor.me").font(archivo(19, "Black")).tracking(-1)
            Spacer()
            Label("NEW YORK CITY", systemImage: "location.fill")
                .font(.system(size: 9, weight: .bold)).tracking(1.2).foregroundStyle(ComedyPalette.muted)
        }
    }
    private var marquee: some View {
        VStack(alignment: .leading, spacing: 24) {
            location
            VStack(alignment: .leading, spacing: 7) {
                Text("Your next\ngood night.").font(archivo(46, "Black")).tracking(-2).lineSpacing(-2)
                Text("Great comics. Small rooms. Go laugh.")
                    .font(archivo(13)).foregroundStyle(ComedyPalette.muted)
            }
            dateChips
            Button { selectedShow = MockShow.samples[0] } label: {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Label("THE SPOTLIGHT", systemImage: "sparkle").font(.system(size: 9, weight: .heavy)).tracking(2)
                        Spacer()
                        Text("01 / 03").font(.system(size: 10, design: .monospaced))
                    }
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("GOOD\nEGGS").font(archivo(54, "Black")).tracking(-2).lineSpacing(-6)
                            Text("A VERY GOOD NIGHT OF STAND-UP").font(.system(size: 8, weight: .heavy)).tracking(1)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "mic.fill").font(.system(size: 77, weight: .black)).rotationEffect(.degrees(17))
                            .padding(.bottom, 14).accessibilityHidden(true)
                    }.padding(.top, 25).padding(.bottom, 22)
                    Rectangle().frame(height: 1).opacity(0.25)
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("New York Comedy Club").font(archivo(12, "Bold"))
                            Text("\(dayLabel) · 7:00 PM · From $25").font(archivo(11))
                        }
                        Spacer()
                            .frame(width: 36, height: 36).background(ComedyPalette.background, in: Circle()).foregroundStyle(ComedyPalette.blush)
                    }.padding(.top, 17)
                }.padding(22).foregroundStyle(ComedyPalette.background)
                    .background(ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 8))
            }.buttonStyle(.plain)
            HStack {
                Text("Also worth staying out for").font(archivo(17, "Bold"))
                Spacer()
                Text("02").font(.system(size: 11, design: .monospaced)).foregroundStyle(ComedyPalette.orange)
            }
            compactRow(MockShow.samples[1])
            compactRow(MockShow.samples[2])
        }
    }

    private var showCards: some View {
        VStack(alignment: .leading, spacing: 23) {
            location
            VStack(alignment: .leading, spacing: 0) {
                Text("Find your").foregroundStyle(ComedyPalette.blush)
                Text("funny.").foregroundStyle(ComedyPalette.sage)
            }.font(archivo(43, "Black")).tracking(-1.8)
            Text("Good company. Great comedy.")
                .font(archivo(12)).foregroundStyle(ComedyPalette.muted)
            dateChips
            HStack {
                Text("ON AROUND YOU").font(.system(size: 9, weight: .bold)).tracking(1.8)
                Spacer()
                Text("3 shows").font(archivo(11)).foregroundStyle(ComedyPalette.muted)
            }
            ForEach(MockShow.samples) { show in
                Button { selectedShow = show } label: {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(show.neighborhood.uppercased()).font(.system(size: 8, weight: .heavy)).tracking(1.5)
                                Text(show.title).font(archivo(25, "Black")).tracking(-1)
                                Text(show.venue).font(archivo(11))
                            }
                            Spacer(minLength: 8)
                            VStack(alignment: .trailing, spacing: 1) {
                                Text(show.time).font(archivo(22, "Bold"))
                                Text("PM").font(.system(size: 9, weight: .bold)).tracking(2)
                            }
                        }
                        Text(show.lineup.replacingOccurrences(of: "\n", with: " · "))
                            .font(archivo(11)).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                        Rectangle().fill(ComedyPalette.background.opacity(0.18)).frame(height: 1)
                        HStack {
                            Text(dayLabel).font(archivo(11, "Bold"))
                            Spacer()
                            PricePill(text: show.price)
                        }
                    }.padding(20).foregroundStyle(ComedyPalette.background)
                        .background(show.id == 2 ? ComedyPalette.blush : ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 14))
                }.buttonStyle(.plain)
            }
        }
    }

    private var tonight: some View {
        VStack(alignment: .leading, spacing: 25) {
            location
            VStack(alignment: .leading, spacing: 9) {
                Text("LESS SCROLLING. MORE LAUGHING.").font(.system(size: 8, weight: .bold)).tracking(1.6).foregroundStyle(ComedyPalette.orange)
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("Tonight").font(archivo(49, "Black")).tracking(-2)
                    Text(".").font(archivo(49, "Black")).foregroundStyle(ComedyPalette.sage)
                }
                Text("Three good reasons to leave the couch.").font(archivo(12)).foregroundStyle(ComedyPalette.muted)
            }
            dateChips
            HStack {
                Text(selectedDate == 0 ? "WEDNESDAY, OCT 28" : "THURSDAY, OCT 29")
                    .font(.system(size: 9, weight: .bold)).tracking(1.5)
                Spacer()
                Text("3 SHOWS").font(.system(size: 9, design: .monospaced)).foregroundStyle(ComedyPalette.muted)
            }.padding(.bottom, 2)
            VStack(spacing: 0) {
                ForEach(MockShow.samples) { show in
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(show.time).font(archivo(20, "Bold")).tracking(-1)
                            Text("PM").font(.system(size: 9, weight: .bold)).foregroundStyle(ComedyPalette.muted)
                            Rectangle().fill(ComedyPalette.sage.opacity(0.5)).frame(width: 1, height: 100).padding(.leading, 4).padding(.top, 10)
                        }.frame(width: 55, alignment: .leading)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                Button { selectedShow = show } label: {
                                    Text(show.title).font(archivo(23, "Bold")).tracking(-0.7).multilineTextAlignment(.leading)
                                }.buttonStyle(.plain)
                                Spacer(minLength: 0)
                                saveButton(show)
                            }
                            Text(show.venue).font(archivo(12, "Bold")).foregroundStyle(ComedyPalette.orange)
                            Text(show.lineup).font(archivo(11)).lineSpacing(5).foregroundStyle(ComedyPalette.muted)
                            HStack {
                                Text(show.neighborhood).font(archivo(10))
                                Spacer()
                                Text(show.price).font(archivo(11, "Bold")).padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(ComedyPalette.sage, in: Capsule())
                            }.padding(.top, 4)
                        }.padding(.bottom, 30)
                    }
                }
            }
        }
    }

    private var dayLabel: String { selectedDate == 0 ? "Tonight" : "Tomorrow" }
    private var dateChips: some View {
        HStack(spacing: 8) {
            ForEach(0..<2) { index in
                Button { selectedDate = index } label: {
                    Text(index == 0 ? "Tonight" : "Tomorrow").font(archivo(11, "Bold"))
                        .padding(.horizontal, 17).padding(.vertical, 12)
                        .background(selectedDate == index ? (concept == 1 ? ComedyPalette.sage : ComedyPalette.blush) : .clear, in: Capsule())
                        .overlay(Capsule().stroke(ComedyPalette.muted.opacity(0.35), lineWidth: selectedDate == index ? 0 : 1))
                        .foregroundStyle(selectedDate == index ? ComedyPalette.background : ComedyPalette.blush)
                }.accessibilityAddTraits(selectedDate == index ? .isSelected : [])
            }
            Spacer(minLength: 0)
            Text("NYC / ALL PRICES").font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(ComedyPalette.muted)
        }
    }
    private func compactRow(_ show: MockShow) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(show.time).font(archivo(15, "Bold")).foregroundStyle(ComedyPalette.orange).frame(width: 45, alignment: .leading)
            Button { selectedShow = show } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(show.title).font(archivo(17, "Bold"))
                    Text("\(show.venue) · \(show.price)").font(archivo(10)).foregroundStyle(ComedyPalette.muted)
                }
            }.buttonStyle(.plain)
            Spacer(minLength: 0)
            saveButton(show)
        }.padding(.bottom, 16).overlay(alignment: .bottom) { Rectangle().fill(ComedyPalette.muted.opacity(0.2)).frame(height: 1) }
    }
    private func saveButton(_ show: MockShow) -> some View {
        Button {
            if saved.contains(show.id) { saved.remove(show.id) } else { saved.insert(show.id) }
        } label: {
            Image(systemName: saved.contains(show.id) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16)).foregroundStyle(saved.contains(show.id) ? ComedyPalette.orange : ComedyPalette.muted)
                .frame(width: 28, height: 30)
        }.accessibilityLabel(saved.contains(show.id) ? "Unsave \(show.title)" : "Save \(show.title)")
    }
    private var bottomBar: some View {
        HStack {
            Label("DISCOVER", systemImage: "sparkle").foregroundStyle(ComedyPalette.blush)
            Spacer()
            Label("\(saved.count) SAVED", systemImage: "bookmark").foregroundStyle(ComedyPalette.muted)
        }.font(.system(size: 9, weight: .bold)).tracking(1.6)
            .padding(.horizontal, 30).padding(.vertical, 19)
            .background(ComedyPalette.ink)
            .overlay(alignment: .top) { Rectangle().fill(ComedyPalette.muted.opacity(0.15)).frame(height: 1) }
    }
    private func sampleDetail(_ show: MockShow) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Text("SAMPLE SHOW").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(ComedyPalette.orange)
                Spacer()
                Button("Done") { selectedShow = nil }.tint(ComedyPalette.blush)
            }
            Text(show.title).font(archivo(38, "Black"))
            Text("\(show.venue)\n\(dayLabel) · \(show.time) PM · From \(show.price)").font(archivo(15)).lineSpacing(6)
            Text(show.lineup).font(archivo(18, "Bold")).lineSpacing(8)
            Text("Illustrative lineup and pricing for design review. This is not a bookable event.")
                .font(archivo(12)).foregroundStyle(ComedyPalette.muted)
            Spacer(minLength: 0)
        }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(ComedyPalette.blush).background(ComedyPalette.background)
    }
    private func archivo(_ size: CGFloat, _ weight: String = "Regular") -> Font {
        .custom("Archivo-\(weight)", size: size, relativeTo: .body)
    }
}

struct ShowMockups_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(0..<3) { concept in
            ShowMockupGallery(initialConcept: concept).previewDisplayName(["Marquee", "Show Cards", "Tonight"][concept])
        }
    }
}

/// Three comedian-home studies with inline, illustrative show listings.
struct ComedianHomeMockups: View {
    @Environment(\.dismiss) private var dismiss
    let name: String
    let portrait: String?
    let onClose: (() -> Void)?
    @State private var concept: Int
    @State private var selectedShow: Int?
    private let concepts = ["Spotlight", "Compact", "Agenda"]
    private let venues = ["Comedy Cellar", "New York Comedy Club", "The Stand"]
    private let areas = ["Greenwich Village", "East Village", "Union Square"]
    private let dates = ["FRI, NOV 6", "SAT, NOV 7", "SUN, NOV 8"]
    private let times = ["7:30 PM", "9:00 PM", "8:00 PM"]
    private let prices = ["$25", "$30", "$20"]

    init(name: String = "Sam Morril", portrait: String? = nil, initialConcept: Int = 0, onClose: (() -> Void)? = nil) {
        self.name = name
        self.portrait = portrait
        self.onClose = onClose
        _concept = State(initialValue: min(2, max(0, initialConcept)))
    }
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                HStack {
                    Text("COMEDIAN HOME / SAMPLE CONTENT").font(.system(size: 9, weight: .semibold, design: .monospaced)).tracking(1)
                    Spacer()
                    Button { if let onClose { onClose() } else { dismiss() } } label: {
                        Image(systemName: "xmark").font(.system(size: 12, weight: .bold))
                    }.accessibilityLabel("Close comedian mockups")
                }.foregroundStyle(ComedyPalette.muted)
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Button { concept = index } label: {
                            Text(concepts[index]).font(.custom("Archivo-Bold", size: 11))
                                .frame(maxWidth: .infinity).padding(.vertical, 11)
                                .foregroundStyle(concept == index ? ComedyPalette.background : ComedyPalette.muted)
                                .background(concept == index ? ComedyPalette.blush : .clear, in: Capsule())
                        }.accessibilityAddTraits(concept == index ? .isSelected : [])
                    }
                }
            }.padding(.horizontal, 24).padding(.vertical, 16).background(ComedyPalette.ink)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    if concept == 0 { spotlightHeader }
                    else if concept == 1 { compactHeader }
                    else { agendaHeader }
                    HStack {
                        Text(concept == 2 ? "ON THE CALENDAR" : "UPCOMING SHOWS")
                            .font(.custom("Archivo-Bold", size: 10)).tracking(1.8)
                        Spacer()
                        Text("3 shows").font(.custom("Archivo-Regular", size: 11)).foregroundStyle(ComedyPalette.muted)
                    }
                    VStack(spacing: concept == 2 ? 0 : 14) {
                        ForEach(0..<3) { index in
                            Button { selectedShow = index } label: {
                                if concept == 2 { agendaRow(index) } else { showCard(index) }
                            }.buttonStyle(.plain)
                        }
                    }
                    Text("Illustrative dates, venues and prices for design review.")
                        .font(.custom("Archivo-Regular", size: 10)).foregroundStyle(ComedyPalette.muted)
                }.padding(24)
            }.id(concept)
        }
        .foregroundStyle(ComedyPalette.blush)
        .background(ComedyPalette.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(isPresented: Binding(get: { selectedShow != nil }, set: { if !$0 { selectedShow = nil } })) {
            if let index = selectedShow {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Text("SAMPLE SHOW").font(.caption).tracking(2).foregroundStyle(ComedyPalette.orange)
                        Spacer()
                        Button("Done") { selectedShow = nil }
                    }
                    Text(venues[index]).font(.custom("Archivo-Black", size: 30))
                    Text("\(dates[index]) · \(times[index])")
                    PricePill(text: prices[index])
                    Text("Illustrative event for design review. No tickets are available through this mockup.")
                        .font(.subheadline).foregroundStyle(ComedyPalette.muted)
                    Spacer()
                }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundStyle(ComedyPalette.blush).background(ComedyPalette.background).tint(ComedyPalette.blush)
                    .presentationDetents([.medium])
            }
        }
    }

    private var spotlightHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                Text("LIVE &\nIN PERSON").font(.custom("Archivo-Black", size: 12)).tracking(1.2)
                Spacer()
                avatar(size: 102)
            }
            Text(name).font(.custom("Archivo-Black", size: 46)).tracking(-1.8)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("Catch the next set.").font(.custom("Archivo-Regular", size: 13))
                Spacer()
                Image(systemName: "arrow.down").font(.system(size: 18))
            }
        }.padding(24).foregroundStyle(ComedyPalette.background)
            .background(ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 18))
    }
    private var compactHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 18) {
                avatar(size: 88)
                VStack(alignment: .leading, spacing: 8) {
                    Text(name).font(.custom("Archivo-Black", size: 32)).tracking(-1)
                }
                Spacer(minLength: 0)
            }
            Rectangle().fill(ComedyPalette.muted.opacity(0.25)).frame(height: 1)
        }
    }
    private var agendaHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("MAKE A NIGHT OF IT").font(.custom("Archivo-Bold", size: 9)).tracking(2).foregroundStyle(ComedyPalette.orange)
                Spacer()
                avatar(size: 48)
            }
            Text(name).font(.custom("Archivo-Black", size: 48)).tracking(-2)
                .fixedSize(horizontal: false, vertical: true)
            Text("Find a room. Pick a night. See you there.")
                .font(.custom("Archivo-Regular", size: 12)).foregroundStyle(ComedyPalette.muted)
        }
    }
    private func avatar(size: CGFloat) -> some View {
        AsyncImage(url: portrait.flatMap(webURL)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Text(name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined())
                .font(.custom("Archivo-Black", size: size * 0.32))
                .foregroundStyle(ComedyPalette.blush)
                .frame(width: size, height: size).background(ComedyPalette.ink)
        }.frame(width: size, height: size).clipShape(Circle()).accessibilityHidden(true)
    }
    private func showCard(_ index: Int) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(dates[index]).font(.custom("Archivo-Bold", size: 10)).tracking(1)
                Spacer()
                Text(times[index]).font(.custom("Archivo-Bold", size: 12))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(venues[index]).font(.custom("Archivo-Black", size: 24)).tracking(-0.6)
                Text(areas[index]).font(.custom("Archivo-Regular", size: 11))
            }
            HStack {
                Text("Lineup show").font(.custom("Archivo-Regular", size: 11))
                Spacer()
                PricePill(text: prices[index])
            }
        }.padding(20).foregroundStyle(ComedyPalette.background)
            .background(concept == 0 || index % 2 == 1 ? ComedyPalette.blush : ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 14))
            .multilineTextAlignment(.leading)
    }
    private func agendaRow(_ index: Int) -> some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 5) {
                Text(["FRI", "SAT", "SUN"][index]).font(.custom("Archivo-Bold", size: 9)).tracking(1.3)
                Text(String(index + 6)).font(.custom("Archivo-Black", size: 30))
                Text("NOV").font(.custom("Archivo-Regular", size: 9)).tracking(1)
            }.frame(width: 56).padding(.vertical, 12)
                .foregroundStyle(ComedyPalette.background).background(ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 10) {
                Text(times[index]).font(.custom("Archivo-Bold", size: 12)).foregroundStyle(ComedyPalette.orange)
                Text(venues[index]).font(.custom("Archivo-Bold", size: 23)).tracking(-0.5)
                Text(areas[index]).font(.custom("Archivo-Regular", size: 11)).foregroundStyle(ComedyPalette.muted)
                HStack {
                    PricePill(text: prices[index])
                    Spacer()
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.vertical, 22)
            .overlay(alignment: .bottom) { Rectangle().fill(ComedyPalette.muted.opacity(0.22)).frame(height: 1) }
            .multilineTextAlignment(.leading)
    }
}

struct ComedianHomeMockups_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(0..<3) { index in
            ComedianHomeMockups(initialConcept: index).previewDisplayName(["Spotlight", "Compact", "Agenda"][index])
        }
    }
}
