import Foundation

protocol SerpAPIClient {
    func searchProducts(query: String, location: String?, limit: Int) async throws -> [Product]
}

enum SerpAPIClientError: Error {
    case notImplemented
}

final class PlaceholderSerpAPIClient: SerpAPIClient {
    private let mapper: SerpAPIProductMapping

    init(mapper: SerpAPIProductMapping = SerpAPIMapper()) {
        self.mapper = mapper
    }

    func searchProducts(query: String, location: String?, limit: Int) async throws -> [Product] {
        // Placeholder only; live SerpApi networking comes later.
        let mapped = mapper.map(response: .placeholder)
        return Array(mapped.prefix(max(1, limit)))
    }
}
