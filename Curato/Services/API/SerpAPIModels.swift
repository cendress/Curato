import Foundation

struct SerpApiShoppingResponse: Codable {
    let shoppingResults: [SerpApiShoppingResult]

    enum CodingKeys: String, CodingKey {
        case shoppingResults = "shopping_results"
    }

    init(shoppingResults: [SerpApiShoppingResult]) {
        self.shoppingResults = shoppingResults
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shoppingResults = try container.decodeIfPresent([SerpApiShoppingResult].self, forKey: .shoppingResults) ?? []
    }
}

struct SerpApiShoppingResult: Codable, Hashable {
    let productID: String?
    let title: String?
    let source: String?
    let extractedPrice: Double?
    let extractedOldPrice: Double?
    let rating: Double?
    let reviews: Int?
    let thumbnail: String?
    let thumbnails: [String]
    let productLink: String?
    let snippet: String?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case title
        case source
        case extractedPrice = "extracted_price"
        case extractedOldPrice = "extracted_old_price"
        case rating
        case reviews
        case thumbnail
        case thumbnails
        case productLink = "product_link"
        case snippet
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        productID = Self.decodeString(in: container, for: .productID)
        title = Self.decodeString(in: container, for: .title)
        source = Self.decodeString(in: container, for: .source)
        extractedPrice = Self.decodeDouble(in: container, for: .extractedPrice)
        extractedOldPrice = Self.decodeDouble(in: container, for: .extractedOldPrice)
        rating = Self.decodeDouble(in: container, for: .rating)
        reviews = Self.decodeInt(in: container, for: .reviews)
        thumbnail = Self.decodeString(in: container, for: .thumbnail)
        thumbnails = Self.decodeThumbnailArray(in: container)
        productLink = Self.decodeString(in: container, for: .productLink)
        snippet = Self.decodeString(in: container, for: .snippet)
    }

    private struct ThumbnailObject: Codable {
        let thumbnail: String?
        let image: String?
        let link: String?
        let serpapiThumbnail: String?

        enum CodingKeys: String, CodingKey {
            case thumbnail
            case image
            case link
            case serpapiThumbnail = "serpapi_thumbnail"
        }
    }

    private static func decodeThumbnailArray(in container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let rawStrings = try? container.decodeIfPresent([String].self, forKey: .thumbnails) {
            return rawStrings.filter { !$0.isEmpty }
        }

        if let objects = try? container.decodeIfPresent([ThumbnailObject].self, forKey: .thumbnails) {
            return objects
                .compactMap { $0.thumbnail ?? $0.image ?? $0.link ?? $0.serpapiThumbnail }
                .filter { !$0.isEmpty }
        }

        return []
    }

    private static func decodeString(
        in container: KeyedDecodingContainer<CodingKeys>,
        for key: CodingKeys
    ) -> String? {
        if let value = try? container.decode(String.self, forKey: key) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        if let value = try? container.decode(Int.self, forKey: key) {
            return String(value)
        }

        if let value = try? container.decode(Double.self, forKey: key) {
            return String(value)
        }

        return nil
    }

    private static func decodeDouble(
        in container: KeyedDecodingContainer<CodingKeys>,
        for key: CodingKeys
    ) -> Double? {
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }

        if let value = try? container.decode(Int.self, forKey: key) {
            return Double(value)
        }

        if let value = try? container.decode(String.self, forKey: key),
           let parsed = parseDouble(from: value) {
            return parsed
        }

        return nil
    }

    private static func decodeInt(
        in container: KeyedDecodingContainer<CodingKeys>,
        for key: CodingKeys
    ) -> Int? {
        if let value = try? container.decode(Int.self, forKey: key) {
            return value
        }

        if let value = try? container.decode(Double.self, forKey: key) {
            return Int(value)
        }

        if let value = try? container.decode(String.self, forKey: key),
           let parsed = parseDouble(from: value) {
            return Int(parsed)
        }

        return nil
    }

    private static func parseDouble(from text: String) -> Double? {
        let cleaned = text
            .lowercased()
            .replacingOccurrences(of: ",", with: "")
            .filter { "0123456789.".contains($0) }

        guard !cleaned.isEmpty else { return nil }
        return Double(cleaned)
    }
}
