import Foundation

protocol SerpAPIClient {
    func searchProducts(
        vibeText: String,
        categories: [String],
        budgetMin: Double?,
        budgetMax: Double?,
        location: String,
        gl: String,
        hl: String
    ) async throws -> [Product]
}

enum SerpAPIClientError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case badStatusCode(Int)
    case decodingFailed(String)
    case emptyResults
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing SerpApi API key. Add it to Secrets.serpAPIKey."
        case .invalidURL:
            return "Could not build a valid SerpApi URL."
        case .invalidResponse:
            return "Received an invalid response from SerpApi."
        case .badStatusCode(let code):
            return "SerpApi request failed with status code \(code)."
        case .decodingFailed(let message):
            return "Could not decode SerpApi response: \(message)"
        case .emptyResults:
            return "No products were returned for the current query."
        case .requestFailed(let message):
            return "Network request failed: \(message)"
        }
    }
}

final class LiveSerpAPIClient: SerpAPIClient {
    private let session: URLSession
    private let mapper: SerpAPIProductMapping
    private let baseURL = "https://serpapi.com/search"

    init(
        session: URLSession = .shared,
        mapper: SerpAPIProductMapping = SerpAPIMapper()
    ) {
        self.session = session
        self.mapper = mapper
    }

    func searchProducts(
        vibeText: String,
        categories: [String],
        budgetMin: Double?,
        budgetMax: Double?,
        location: String,
        gl: String,
        hl: String
    ) async throws -> [Product] {
        let apiKey = Secrets.serpAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            throw SerpAPIClientError.missingAPIKey
        }

        let query = buildQuery(vibeText: vibeText, categories: categories)

        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "engine", value: "google_shopping"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "gl", value: normalizedCountryCode(gl)),
            URLQueryItem(name: "hl", value: normalizedLanguageCode(hl)),
            URLQueryItem(name: "location", value: normalizedLocation(location)),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "output", value: "json")
        ]

        if let budgetMin {
            queryItems.append(URLQueryItem(name: "min_price", value: normalizedPriceValue(budgetMin)))
        }

        if let budgetMax {
            queryItems.append(URLQueryItem(name: "max_price", value: normalizedPriceValue(budgetMax)))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw SerpAPIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 25

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw SerpAPIClientError.requestFailed(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SerpAPIClientError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw SerpAPIClientError.badStatusCode(httpResponse.statusCode)
        }

        let decoded: SerpApiShoppingResponse
        do {
            decoded = try JSONDecoder().decode(SerpApiShoppingResponse.self, from: data)
        } catch {
            throw SerpAPIClientError.decodingFailed(error.localizedDescription)
        }

        guard !decoded.shoppingResults.isEmpty else {
            throw SerpAPIClientError.emptyResults
        }

        let mapped = mapper.map(response: decoded, queryUsed: query, requestedCategories: categories)
        guard !mapped.isEmpty else {
            throw SerpAPIClientError.emptyResults
        }

        return mapped
    }

    private func buildQuery(vibeText: String, categories: [String]) -> String {
        let trimmedVibe = vibeText.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCategories = categories
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if !trimmedVibe.isEmpty && !cleanedCategories.isEmpty {
            return "\(trimmedVibe) \(cleanedCategories.joined(separator: " "))"
        }

        if !trimmedVibe.isEmpty {
            return trimmedVibe
        }

        if !cleanedCategories.isEmpty {
            return cleanedCategories.joined(separator: " ")
        }

        return "fashion shopping"
    }

    private func normalizedPriceValue(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(format: "%.2f", value)
    }

    private func normalizedLocation(_ location: String) -> String {
        let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "United States" : trimmed
    }

    private func normalizedCountryCode(_ gl: String) -> String {
        let trimmed = gl.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.isEmpty ? "us" : trimmed
    }

    private func normalizedLanguageCode(_ hl: String) -> String {
        let trimmed = hl.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.isEmpty ? "en" : trimmed
    }
}
