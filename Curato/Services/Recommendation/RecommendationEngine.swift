import Foundation

protocol Recommending {
    func scoreProduct(
        product: Product,
        profile: UserPreferenceProfile?,
        vibeTags: [String],
        selectedCategories: [String],
        budgetMin: Double?,
        budgetMax: Double?
    ) -> Double

    func rerankProducts(
        products: [Product],
        profile: UserPreferenceProfile?,
        vibeText: String,
        selectedCategories: [String],
        budgetMin: Double?,
        budgetMax: Double?
    ) -> [Product]
}

struct RecommendationEngine: Recommending {
    private let vibeParser: VibeParsing
    private let tagInferer: ProductTagInferring
    private let reasonBuilder: RecommendationReasonBuilding

    init(
        vibeParser: VibeParsing = VibeParser(),
        tagInferer: ProductTagInferring = ProductTagInferer(),
        reasonBuilder: RecommendationReasonBuilding = RecommendationReasonBuilder()
    ) {
        self.vibeParser = vibeParser
        self.tagInferer = tagInferer
        self.reasonBuilder = reasonBuilder
    }

    func scoreProduct(
        product: Product,
        profile: UserPreferenceProfile?,
        vibeTags: [String],
        selectedCategories: [String],
        budgetMin: Double?,
        budgetMax: Double?
    ) -> Double {
        let inferredTags = Set(tagInferer.inferProductTags(product: product).map(normalize))
        let normalizedVibeTags = Set(vibeTags.map(normalize))
        let normalizedCategories = Set(selectedCategories.map(normalize))

        let matchedVibeTags = inferredTags.intersection(normalizedVibeTags)
        var score = Double(matchedVibeTags.count) * 2.5

        if !normalizedCategories.isEmpty {
            if let category = product.category.map(normalize), normalizedCategories.contains(category) {
                score += 3.2
            } else if !inferredTags.intersection(normalizedCategories).isEmpty {
                score += 2.0
            } else {
                score -= 0.9
            }
        }

        score += budgetComponent(price: product.price, budgetMin: budgetMin, budgetMax: budgetMax)

        if let profile {
            score += preferenceWeightComponent(tags: inferredTags, profile: profile)

            if profile.savedProductIDs.contains(product.id) {
                score += 1.1
            }

            if profile.likedProductIDs.contains(product.id) {
                score += 0.8
            }

            if profile.skippedProductIDs.contains(product.id) {
                score -= 2.2
            }
        }

        if let rating = product.rating {
            score += max(0, rating - 3.5) * 0.5
        }

        if let reviews = product.reviewCount {
            if reviews > 750 {
                score += 0.5
            } else if reviews > 150 {
                score += 0.25
            }
        }

        return score
    }

    func rerankProducts(
        products: [Product],
        profile: UserPreferenceProfile?,
        vibeText: String,
        selectedCategories: [String],
        budgetMin: Double?,
        budgetMax: Double?
    ) -> [Product] {
        let vibeTags = vibeParser.parseVibeText(vibeText)

        let scoredProducts = products.map { product -> (Product, Double) in
            let explanation = buildExplanation(
                product: product,
                profile: profile,
                vibeTags: vibeTags,
                selectedCategories: selectedCategories,
                budgetMin: budgetMin,
                budgetMax: budgetMax
            )

            let score = scoreProduct(
                product: product,
                profile: profile,
                vibeTags: vibeTags,
                selectedCategories: selectedCategories,
                budgetMin: budgetMin,
                budgetMax: budgetMax
            )

            let reason = reasonBuilder.buildReason(explanation: explanation)
            let inferredTags = tagInferer.inferProductTags(product: product)
            let mergedTags = unique(product.tags + inferredTags)

            let enriched = Product(
                id: product.id,
                title: product.title,
                merchant: product.merchant,
                price: product.price,
                originalPrice: product.originalPrice,
                rating: product.rating,
                reviewCount: product.reviewCount,
                imageURL: product.imageURL,
                thumbnailURLs: product.thumbnailURLs,
                productURL: product.productURL,
                queryUsed: product.queryUsed,
                snippet: product.snippet,
                reasonText: reason,
                tags: mergedTags,
                category: product.category
            )

            return (enriched, score)
        }

        return scoredProducts
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.title < rhs.0.title
                }
                return lhs.1 > rhs.1
            }
            .map(\.0)
    }

    private func buildExplanation(
        product: Product,
        profile: UserPreferenceProfile?,
        vibeTags: [String],
        selectedCategories: [String],
        budgetMin: Double?,
        budgetMax: Double?
    ) -> RecommendationExplanation {
        let normalizedInferredTags = Set(tagInferer.inferProductTags(product: product).map(normalize))
        let normalizedVibeTags = Set(vibeTags.map(normalize))

        let matchedVibeTags = normalizedInferredTags
            .intersection(normalizedVibeTags)
            .sorted()

        let matchedPreferenceTags: [String]
        if let profile {
            matchedPreferenceTags = normalizedInferredTags
                .filter { (profile.positiveTagWeights[$0] ?? 0) > 0.75 }
                .sorted()
        } else {
            matchedPreferenceTags = []
        }

        let normalizedSelectedCategories = Set(selectedCategories.map(normalize))
        let matchedCategory: String?
        if let category = product.category?.lowercased(), normalizedSelectedCategories.contains(category) {
            matchedCategory = category
        } else {
            matchedCategory = normalizedSelectedCategories.first(where: { normalizedInferredTags.contains($0) })
        }

        let isWithinBudget = isPriceWithinBudget(product.price, budgetMin: budgetMin, budgetMax: budgetMax)
        let hasStrongRating = (product.rating ?? 0) >= 4.4 || (product.reviewCount ?? 0) >= 400

        return RecommendationExplanation(
            matchedVibeTags: matchedVibeTags,
            matchedPreferenceTags: matchedPreferenceTags,
            matchedCategory: matchedCategory,
            isWithinBudget: isWithinBudget,
            hasStrongRating: hasStrongRating
        )
    }

    private func budgetComponent(price: Double?, budgetMin: Double?, budgetMax: Double?) -> Double {
        guard budgetMin != nil || budgetMax != nil else {
            return 0
        }

        guard let price else {
            return -0.4
        }

        if isPriceWithinBudget(price, budgetMin: budgetMin, budgetMax: budgetMax) {
            return 2.8
        }

        if let min = budgetMin, price < min {
            let ratio = (min - price) / Swift.max(min, 1)
            return -Swift.min(3.5, ratio * 4)
        }

        if let maxBudget = budgetMax, price > maxBudget {
            let ratio = (price - maxBudget) / Swift.max(maxBudget, 1)
            return -Swift.min(3.5, ratio * 4)
        }

        return -0.6
    }

    private func isPriceWithinBudget(_ price: Double?, budgetMin: Double?, budgetMax: Double?) -> Bool {
        guard let price else {
            return budgetMin == nil && budgetMax == nil
        }

        if let budgetMin, price < budgetMin {
            return false
        }

        if let budgetMax, price > budgetMax {
            return false
        }

        return true
    }

    private func preferenceWeightComponent(tags: Set<String>, profile: UserPreferenceProfile) -> Double {
        tags.reduce(0) { partial, tag in
            partial + (profile.positiveTagWeights[tag] ?? 0) - (profile.negativeTagWeights[tag] ?? 0)
        }
    }

    private func unique(_ items: [String]) -> [String] {
        var seen = Set<String>()
        var uniqueItems: [String] = []

        for item in items {
            let normalized = normalize(item)
            guard !normalized.isEmpty, seen.insert(normalized).inserted else { continue }
            uniqueItems.append(normalized)
        }

        return uniqueItems
    }

    private func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
