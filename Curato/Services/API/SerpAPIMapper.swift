import Foundation

protocol SerpAPIProductMapping {
    func map(
        response: SerpApiShoppingResponse,
        queryUsed: String,
        requestedCategories: [String]
    ) -> [Product]
}

struct SerpAPIMapper: SerpAPIProductMapping {
    func map(
        response: SerpApiShoppingResponse,
        queryUsed: String,
        requestedCategories: [String]
    ) -> [Product] {
        response.shoppingResults.compactMap { result in
            guard let title = result.title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
                return nil
            }

            let merchant = (result.source?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap {
                $0.isEmpty ? nil : $0
            } ?? "Unknown Merchant"

            let allThumbnails = normalizeThumbnails(primary: result.thumbnail, fallback: result.thumbnails)
            let primaryImage = allThumbnails.first
            let inferredCategory = inferCategory(for: result, requestedCategories: requestedCategories)

            return Product(
                id: stableID(from: result, fallbackTitle: title, merchant: merchant),
                title: title,
                merchant: merchant,
                price: result.extractedPrice,
                originalPrice: result.extractedOldPrice,
                rating: result.rating,
                reviewCount: result.reviews,
                imageURL: primaryImage,
                thumbnailURLs: allThumbnails,
                productURL: result.productLink,
                queryUsed: queryUsed,
                snippet: result.snippet,
                reasonText: nil,
                tags: [],
                category: inferredCategory
            )
        }
    }

    private func stableID(from result: SerpApiShoppingResult, fallbackTitle: String, merchant: String) -> String {
        if let rawID = result.productID?.trimmingCharacters(in: .whitespacesAndNewlines), !rawID.isEmpty {
            return rawID
        }

        if let productLink = result.productLink?.trimmingCharacters(in: .whitespacesAndNewlines), !productLink.isEmpty {
            return productLink
        }

        let normalized = "\(merchant)-\(fallbackTitle)"
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        return normalized.isEmpty ? UUID().uuidString : normalized
    }

    private func normalizeThumbnails(primary: String?, fallback: [String]) -> [String] {
        let combined = ([primary].compactMap { $0 } + fallback)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var seen = Set<String>()
        var unique: [String] = []

        for url in combined where seen.insert(url).inserted {
            unique.append(url)
        }

        return unique
    }

    private func inferCategory(for result: SerpApiShoppingResult, requestedCategories: [String]) -> String? {
        let normalizedRequested = requestedCategories
            .map(normalize)
            .filter { !$0.isEmpty }

        if !normalizedRequested.isEmpty {
            let haystack = normalize([
                result.title,
                result.snippet,
                result.source
            ].compactMap { $0 }.joined(separator: " "))

            if let matched = normalizedRequested.first(where: { haystack.contains($0) }) {
                return matched.capitalized
            }
        }

        let inferred = inferFromCommonTaxonomy(text: [result.title, result.snippet].compactMap { $0 }.joined(separator: " "))
        return inferred
    }

    private func inferFromCommonTaxonomy(text: String) -> String? {
        let normalized = normalize(text)

        let taxonomy: [String: [String]] = [
            "Tops": ["shirt", "tee", "t-shirt", "blouse", "sweater", "hoodie", "polo"],
            "Pants": ["pant", "jean", "trouser", "cargo", "chino", "legging"],
            "Shoes": ["shoe", "sneaker", "loafer", "boot", "heel", "sandal"],
            "Outerwear": ["jacket", "coat", "parka", "windbreaker", "blazer"],
            "Accessories": ["belt", "bag", "watch", "jewelry", "hat", "wallet"]
        ]

        for (category, keywords) in taxonomy {
            if keywords.contains(where: { normalized.contains($0) }) {
                return category
            }
        }

        return nil
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9 ]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
