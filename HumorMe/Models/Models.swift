import Foundation

struct Show: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let venue: String
    let city: String
    let date: String
    let time: String
    let spot: String
    let address: String
    let comics: [String]
    let url: String
    let image: String
    let cost: String
    let fee: String

    enum CodingKeys: String, CodingKey {
        case id = "_id", title, venue, city, date, time, spot, address, comics, url, image, cost, fee
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        venue = c.text(.venue)
        let suppliedTitle = c.text(.title)
        title = suppliedTitle.isEmpty ? venue : suppliedTitle
        city = c.text(.city); date = c.text(.date); time = c.text(.time)
        spot = c.text(.spot); address = c.text(.address)
        comics = try c.decodeIfPresent([String].self, forKey: .comics) ?? []
        url = c.text(.url); image = c.text(.image)
        cost = c.text(.cost); fee = c.text(.fee)
    }
    var price: Double? { Double(cost.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) }
    var minutesAfterMidnight: Int {
        let normalized = time.uppercased().replacingOccurrences(of: " ", with: "")
        let isAM = normalized.hasSuffix("AM")
        let isPM = normalized.hasSuffix("PM")
        let clock = normalized.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "")
        let parts = clock.split(separator: ":")
        guard let first = parts.first, var hour = Int(first), parts.count <= 2,
              let minute = parts.count == 2 ? Int(parts[1]) : 0,
              (0...59).contains(minute) else { return Int.max }
        if isAM || isPM {
            guard (1...12).contains(hour) else { return Int.max }
            hour = hour % 12 + (isPM ? 12 : 0)
        } else if !(0...23).contains(hour) { return Int.max }
        return hour * 60 + minute
    }
    var priceLabel: String {
        guard let price else { return cost.isEmpty ? "See venue for price" : cost }
        return price == 0 ? "Free" : price.formatted(.currency(code: "USD"))
    }
    var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let value = formatter.date(from: date) else { return date }
        formatter.dateStyle = .full
        return formatter.string(from: value)
    }
}

struct Comedian: Decodable, Identifiable, Hashable {
    let comedian: String
    let profile_image: String?
    var id: String { comedian }
}

struct Venue: Decodable, Identifiable {
    let name: String
    let city: String?
    let address: String?
    var id: String { name }
}

extension KeyedDecodingContainer {
    // Scrapers have historically written prices as both strings and numbers.
    func text(_ key: Key) -> String {
        if let value = try? decode(String.self, forKey: key) { return value }
        if let value = try? decode(Double.self, forKey: key) { return String(value) }
        return ""
    }
}

struct ShowFilter: Equatable {
    var cities: Set<String> = []
    var comedians: Set<String> = []
    var datesEnabled = false
    var startDate = Date()
    var endDate = Date()
    var maximumPrice = ""

    var path: [String] {
        var result = ["shows"]
        if !cities.isEmpty { result += ["where", cities.sorted().joined(separator: "+")] }
        if datesEnabled {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            result += ["when", formatter.string(from: startDate) + ":" + formatter.string(from: max(startDate, endDate))]
        }
        if !comedians.isEmpty { result += ["who", comedians.sorted().joined(separator: "+")] }
        if let price = Double(maximumPrice), price >= 0 { result += ["price", maximumPrice] }
        return result
    }
}

func webURL(_ value: String) -> URL? {
    guard let url = URL(string: value), ["https", "http"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else { return nil }
    return url
}
