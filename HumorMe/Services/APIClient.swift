import Foundation

struct APIClient {
    let baseURL: URL
    var session: URLSession = .shared

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    static func configured() throws -> APIClient {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "HumorMeAPIURL") as? String,
              let url = webURL(value), url.scheme == "https" else {
            throw AppError.message("Set a valid HTTPS HumorMeAPIURL in Config.plist before connecting to HumorMe.")
        }
        return APIClient(baseURL: url)
    }

    func url(for path: [String]) throws -> URL {
        // Encode each value as one segment: names containing /, ?, # or & must not change the route.
        let safe = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        let segments = try path.map { segment -> String in
            guard let encoded = segment.addingPercentEncoding(withAllowedCharacters: safe) else {
                throw AppError.message("Unable to encode this search.")
            }
            return encoded
        }
        guard var parts = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw AppError.message("The API address is invalid.")
        }
        parts.percentEncodedPath = parts.percentEncodedPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .split(separator: "/").map(String.init).joined(separator: "/")
        parts.percentEncodedPath = "/" + ([parts.percentEncodedPath].filter { !$0.isEmpty } + segments).joined(separator: "/")
        guard let url = parts.url else { throw AppError.message("The API address is invalid.") }
        return url
    }

    func data(_ path: [String]) async throws -> Data {
        var request = URLRequest(url: try url(for: path))
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AppError.message("HumorMe could not complete the request (HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)). Please try again.")
        }
        return data
    }

    func get<T: Decodable>(_ path: [String]) async throws -> T {
        try JSONDecoder().decode(T.self, from: await data(path))
    }
}

enum AppError: LocalizedError {
    case message(String)
    var errorDescription: String? { if case .message(let value) = self { return value }; return nil }
}
