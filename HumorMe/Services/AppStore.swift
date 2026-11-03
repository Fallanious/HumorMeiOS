import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var comedians: [Comedian] = []
    @Published var venues: [Venue] = []
    @Published var catalogError: String?
    @Published var configurationError: String?
    @Published var loadingCatalog = false
    private(set) var api: APIClient?

    init() {
        do { api = try APIClient.configured() }
        catch { configurationError = error.localizedDescription }
    }

    var cities: [String] { Array(Set(venues.compactMap(\.city))).sorted() }
    func client() throws -> APIClient {
        guard let api else { throw AppError.message(configurationError ?? "API is not configured.") }
        return api
    }
    func loadCatalog() async {
        loadingCatalog = true
        defer { loadingCatalog = false }
        do {
            let api = try client()
            async let comics: [Comedian] = api.get(["comedians"])
            async let locations: [Venue] = api.get(["venues"])
            let result = try await (comics, locations)
            comedians = result.0.sorted { $0.comedian.localizedCaseInsensitiveCompare($1.comedian) == .orderedAscending }
            venues = result.1
            catalogError = nil
        } catch { catalogError = error.localizedDescription }
    }
}
