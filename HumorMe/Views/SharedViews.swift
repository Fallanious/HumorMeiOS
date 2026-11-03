import SwiftUI

enum ComedyPalette {
    static let background = Color(hex: 0x210804)
    static let ink = Color(hex: 0x150503)
    static let blush = Color(hex: 0xFFE9E5)
    static let sage = Color(hex: 0x59876F)
    static let orange = Color(hex: 0xFD983B)
    static let muted = Color(hex: 0xBA9E80)
}

private extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
    }
}


struct MessageView: View {
    let title: String
    let message: String
    var retry: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.headline)
            Text(message).foregroundStyle(.secondary)
            if let retry {
                Button(action: retry) {
                    Text("Try Again")
                        .font(.custom("Archivo-Bold", size: 14, relativeTo: .headline))
                        .foregroundStyle(ComedyPalette.background)
                        .padding(.horizontal, 24)
                        .frame(minHeight: 48)
                        .background(ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }.multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(24)
    }
}
struct Portrait: View {
    let source: String?
    var body: some View {
        AsyncImage(url: source.flatMap(webURL)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: "person.crop.circle.fill").resizable().foregroundStyle(.secondary)
        }.frame(width: 64, height: 64).clipShape(Circle()).accessibilityHidden(true)
    }
}
struct PricePill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.custom("Archivo-Bold", size: 11, relativeTo: .caption))
            .foregroundStyle(ComedyPalette.background)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(ComedyPalette.orange, in: Capsule())
    }
}

struct ShowRow: View {
    let show: Show
    var alternate = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(show.city.uppercased())
                        .font(.custom("Archivo-Bold", size: 9, relativeTo: .caption)).tracking(1.4)
                    Text(show.title)
                        .font(.custom("Archivo-Black", size: 23, relativeTo: .title2)).tracking(-0.7)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(show.venue).font(.custom("Archivo-Regular", size: 12, relativeTo: .subheadline))
                }
                Spacer(minLength: 0)
                Text(show.time)
                    .font(.custom("Archivo-Bold", size: 17, relativeTo: .headline))
                    .fixedSize(horizontal: true, vertical: false)
            }
            Rectangle().fill(ComedyPalette.background.opacity(0.18)).frame(height: 1)
            HStack(alignment: .center, spacing: 10) {
                Text(show.dateLabel).font(.custom("Archivo-Bold", size: 10, relativeTo: .caption))
                Spacer(minLength: 0)
                PricePill(text: show.cost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "See price" : show.priceLabel)
                    .accessibilityLabel(show.priceLabel)
            }
        }
        .padding(20)
        .foregroundStyle(ComedyPalette.background)
        .background(alternate ? ComedyPalette.blush : ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 14))
        .multilineTextAlignment(.leading)
    }
}
struct ComedianCompactHeader: View {
    let name: String
    let portrait: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 18) {
                AsyncImage(url: portrait.flatMap(webURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Text(name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined())
                        .font(.custom("Archivo-Black", size: 28))
                        .foregroundStyle(ComedyPalette.blush)
                        .frame(width: 88, height: 88).background(ComedyPalette.ink)
                }
                .frame(width: 88, height: 88).clipShape(Circle()).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.custom("Archivo-Black", size: 32, relativeTo: .title)).tracking(-1)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            Rectangle().fill(ComedyPalette.muted.opacity(0.25)).frame(height: 1)
        }
    }
}

struct ComedianShowRow: View {
    let show: Show
    var alternate = false

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: show.date) else { return show.date }
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                Text(dateLabel)
                    .font(.custom("Archivo-Bold", size: 10, relativeTo: .caption)).tracking(1)
                    .accessibilityLabel(show.dateLabel)
                Spacer()
                Text(show.time).font(.custom("Archivo-Bold", size: 12, relativeTo: .subheadline))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(show.venue.isEmpty ? show.title : show.venue)
                    .font(.custom("Archivo-Black", size: 24, relativeTo: .title2)).tracking(-0.6)
                    .fixedSize(horizontal: false, vertical: true)
                if !show.city.isEmpty {
                    Text(show.city).font(.custom("Archivo-Regular", size: 11, relativeTo: .caption))
                }
            }
            HStack(spacing: 10) {
                if show.title != show.venue {
                    Text(show.title)
                        .font(.custom("Archivo-Regular", size: 11, relativeTo: .caption))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                PricePill(text: show.cost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "See price" : show.priceLabel)
                    .accessibilityLabel(show.priceLabel)
            }
        }
        .padding(20).foregroundStyle(ComedyPalette.background)
        .background(alternate ? ComedyPalette.blush : ComedyPalette.sage, in: RoundedRectangle(cornerRadius: 14))
        .multilineTextAlignment(.leading)
    }
}

struct MultipleSelection: View {
    let title: String
    let options: [String]
    @Binding var selection: Set<String>
    @State private var search = ""
    var body: some View {
        List(options.filter { search.isEmpty || $0.localizedCaseInsensitiveContains(search) }, id: \.self) { value in
            Button {
                if selection.contains(value) { selection.remove(value) } else { selection.insert(value) }
            } label: {
                HStack {
                    Text(value).foregroundStyle(.primary)
                    Spacer()
                    if selection.contains(value) { Image(systemName: "checkmark") }
                }
            }.accessibilityAddTraits(selection.contains(value) ? .isSelected : [])
        }.navigationTitle(title).searchable(text: $search)
    }
}

struct ComedySearchField: View {
    @Binding var text: String
    let placeholder: String
    let accessibilityLabel: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").foregroundStyle(ComedyPalette.muted)
            TextField(placeholder, text: $text)
                .font(.custom("Archivo-Regular", size: 14, relativeTo: .body))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .accessibilityLabel(accessibilityLabel)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(ComedyPalette.muted)
                }.accessibilityLabel("Clear search")
            }
        }
        .foregroundStyle(ComedyPalette.blush)
        .padding(.horizontal, 16).padding(.vertical, 15)
        .background(ComedyPalette.blush.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(ComedyPalette.muted.opacity(0.2)))
    }
}
