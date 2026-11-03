import XCTest
@testable import HumorMeCore

final class CoreTests: XCTestCase {
    func testShowTimesSortChronologicallyAcrossFormats() throws {
        let times = ["10:00PM", "7:00PM", "12:00AM", "12:00PM", "19:30", "TBD"]
        let data = try JSONSerialization.data(withJSONObject: times.enumerated().map { ["_id": String($0.offset), "time": $0.element] })
        let shows = try JSONDecoder().decode([Show].self, from: data)
        XCTAssertEqual(shows.map(\.minutesAfterMidnight), [1320, 1140, 0, 720, 1170, Int.max])
        XCTAssertEqual(shows.sorted { $0.minutesAfterMidnight < $1.minutesAfterMidnight }.map(\.time), ["12:00AM", "12:00PM", "7:00PM", "19:30", "10:00PM", "TBD"])
    }
    func testMixedPriceTypesAndMissingFields() throws {
        let data = Data(#"[{"_id":"free","venue":"Club","cost":0,"comics":null},{"_id":"paid","venue":"Club","cost":"25.50"},{"_id":"unknown","venue":"Club","cost":"See website"}]"#.utf8)
        let shows = try JSONDecoder().decode([Show].self, from: data)
        XCTAssertEqual(shows[0].price, 0)
        XCTAssertEqual(shows[0].priceLabel, "Free")
        XCTAssertEqual(shows[0].title, "Club")
        XCTAssertEqual(shows[0].comics, [])
        XCTAssertEqual(shows[1].price, 25.5)
        XCTAssertNil(shows[2].price)
        XCTAssertEqual(shows[2].priceLabel, "See website")
    }
    func testCombinedFilterOrderAndZeroPrice() {
        var filter = ShowFilter()
        filter.cities = ["New York", "Boston"]
        filter.comedians = ["Jane Doe"]
        filter.maximumPrice = "0"
        XCTAssertEqual(filter.path, ["shows", "where", "Boston+New York", "who", "Jane Doe", "price", "0"])
        filter.maximumPrice = "invalid"
        XCTAssertFalse(filter.path.contains("price"))
    }
    func testDateRangeIsOrderedAndUsesLocalCalendarDate() {
        var filter = ShowFilter()
        let calendar = Calendar.current
        filter.datesEnabled = true
        filter.startDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31))!
        filter.endDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 30))!
        XCTAssertEqual(filter.path, ["shows", "when", "2026-12-31:2026-12-31"])
    }
    func testPathsPreserveAPIStageAndEncodeNames() throws {
        let api = APIClient(baseURL: URL(string: "https://example.com/dev/")!)
        let url = try api.url(for: ["shows", "comic", "A/B & C?#"])
        XCTAssertEqual(url.absoluteString, "https://example.com/dev/shows/comic/A%2FB%20%26%20C%3F%23")
        let root = APIClient(baseURL: URL(string: "https://example.com")!)
        XCTAssertEqual(try root.url(for: ["shows"]).absoluteString, "https://example.com/shows")
    }
    func testExternalLinksRejectNonWebSchemes() {
        XCTAssertNil(webURL("javascript:alert(1)"))
        XCTAssertNil(webURL("file:///tmp/test"))
        XCTAssertNil(webURL(""))
        XCTAssertNotNil(webURL("https://example.com/tickets"))
    }
    func testHTTPFailureIsNotDecodedAsSuccess() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [FailureProtocol.self]
        let api = APIClient(baseURL: URL(string: "https://example.com")!, session: URLSession(configuration: config))
        do {
            let _: [Show] = try await api.get(["shows"])
            XCTFail("Expected an HTTP error")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("HTTP 503"))
        }
    }
}
private final class FailureProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("Service unavailable".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() { }
}
