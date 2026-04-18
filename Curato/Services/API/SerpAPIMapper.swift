import Foundation

protocol SerpAPIProductMapping {
    func map(
        response: SerpApiShoppingResponse,
        queryUsed: String,
        requestedCategories: [String]
    ) -> [Product]
}

struct SerpAPIMapper: SerpAPIProductMapping {
    private let apparelKeywords: [String] = [
        "apparel", "fashion", "clothing", "outfit", "outfits",
        "dress", "gown", "top", "tops", "shirt", "t shirt", "tee", "blouse", "tank", "camisole", "bodysuit", "polo",
        "sweater", "cardigan", "hoodie", "sweatshirt",
        "jacket", "coat", "parka", "windbreaker", "blazer", "vest",
        "jean", "jeans", "denim", "pant", "pants", "trouser", "trousers", "chino", "chinos", "jogger", "joggers", "legging", "leggings", "shorts", "skirt",
        "shoe", "shoes", "sneaker", "sneakers", "boot", "boots", "heel", "heels", "sandal", "sandals", "loafer", "loafers", "mule", "mules", "clog", "clogs",
        "bag", "bags", "handbag", "tote", "backpack", "belt", "scarf", "hat", "cap", "beanie", "wallet", "jewelry", "necklace", "bracelet", "earring", "ring", "sunglasses",
        "activewear", "loungewear", "swimwear", "bikini", "bra", "underwear", "lingerie", "sock", "socks", "pajama", "pajamas", "romper", "jumpsuit"
    ]

    private let excludedVerticalKeywords: [String] = [
        "iphone", "ipad", "macbook", "laptop", "tablet", "smartphone", "cell phone", "android", "samsung", "pixel", "galaxy",
        "airpods", "earbuds", "headphones", "speaker", "tv", "television", "monitor", "keyboard", "mouse", "router",
        "camera", "lens", "printer", "console", "playstation", "xbox", "nintendo", "gpu", "cpu", "ssd", "hard drive",
        "charger", "cable", "screen protector", "microwave", "refrigerator", "vacuum", "sofa", "mattress", "desk", "tool", "supplement", "book", "toy", "lego"
    ]

    func map(
        response: SerpApiShoppingResponse,
        queryUsed: String,
        requestedCategories: [String]
    ) -> [Product] {
        response.shoppingResults.compactMap { result in
            guard let title = result.title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
                return nil
            }

            let inferredCategory = inferCategory(for: result, requestedCategories: requestedCategories)
            guard isClothingResult(result: result, inferredCategory: inferredCategory, requestedCategories: requestedCategories) else {
                return nil
            }

            let merchant = (result.source?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap {
                $0.isEmpty ? nil : $0
            } ?? "Unknown Merchant"

            let allThumbnails = normalizeThumbnails(primary: result.thumbnail, fallback: result.thumbnails)
            let primaryImage = allThumbnails.first

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

    private func isClothingResult(
        result: SerpApiShoppingResult,
        inferredCategory: String?,
        requestedCategories: [String]
    ) -> Bool {
        let haystack = normalize(
            [
                result.title,
                result.snippet,
                result.source,
                inferredCategory
            ]
            .compactMap { $0 }
            .joined(separator: " ")
        )

        let apparelMatches = countMatches(in: haystack, keywords: apparelKeywords)
        let requestedMatches = countMatches(in: haystack, keywords: requestedCategoryKeywords(for: requestedCategories))
        let excludedMatches = countMatches(in: haystack, keywords: excludedVerticalKeywords)

        let totalPositiveSignal = apparelMatches + requestedMatches

        if totalPositiveSignal == 0 {
            return false
        }

        if excludedMatches == 0 {
            return true
        }

        if apparelMatches == 0 && excludedMatches >= 2 {
            return false
        }

        return excludedMatches <= totalPositiveSignal + 1
    }

    private func countMatches(in text: String, keywords: [String]) -> Int {
        keywords.reduce(into: 0) { partialResult, keyword in
            if containsKeyword(in: text, keyword: keyword) {
                partialResult += 1
            }
        }
    }

    private func containsKeyword(in text: String, keyword: String) -> Bool {
        let normalizedKeyword = normalize(keyword)
        guard !normalizedKeyword.isEmpty else { return false }

        if normalizedKeyword.contains(" ") {
            return text.contains(normalizedKeyword)
        }

        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: normalizedKeyword))\\b"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private func requestedCategoryKeywords(for categories: [String]) -> [String] {
        categories
            .flatMap { category -> [String] in
                switch normalize(category) {
                case "tops":
                    return ["top", "tops", "shirt", "tee", "blouse", "sweater", "hoodie", "polo"]
                case "pants":
                    return ["pant", "pants", "jean", "jeans", "trouser", "trousers", "chino", "shorts", "skirt", "legging", "leggings"]
                case "shoes":
                    return ["shoe", "shoes", "sneaker", "sneakers", "boot", "boots", "heel", "heels", "sandal", "sandals", "loafer", "loafers"]
                case "outerwear":
                    return ["jacket", "coat", "parka", "windbreaker", "blazer", "vest"]
                case "accessories":
                    return ["bag", "bags", "handbag", "tote", "belt", "hat", "cap", "scarf", "wallet", "jewelry", "sunglasses"]
                default:
                    return [category]
                }
            }
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
