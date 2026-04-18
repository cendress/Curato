import Foundation

protocol Recommending {
    func rank(products: [Product], for filters: FilterOptions) -> [Product]
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

    func rank(products: [Product], for filters: FilterOptions) -> [Product] {
        let vibeTags = vibeParser.parseTags(from: filters.vibeText)

        let filteredByBudget = products.filter { product in
            guard let price = product.price else { return true }

            if let min = filters.budgetMin, price < min {
                return false
            }

            if let max = filters.budgetMax, price > max {
                return false
            }

            return true
        }

        let filteredByCategory = filteredByBudget.filter { product in
            guard !filters.selectedCategories.isEmpty else { return true }
            guard let category = product.category else { return false }
            return filters.selectedCategories.contains(category)
        }

        return filteredByCategory
            .sorted { lhs, rhs in
                score(product: lhs, vibeTags: vibeTags) > score(product: rhs, vibeTags: vibeTags)
            }
            .map { product in
                let inferredTags = tagInferer.inferTags(for: product)
                let matchedTags = inferredTags.intersection(vibeTags)
                return Product(
                    id: product.id,
                    title: product.title,
                    merchant: product.merchant,
                    price: product.price,
                    originalPrice: product.originalPrice,
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                    imageURL: product.imageURL,
                    productURL: product.productURL,
                    reasonText: product.reasonText ?? reasonBuilder.buildReason(for: product, matchedTags: matchedTags),
                    tags: product.tags,
                    category: product.category
                )
            }
    }

    private func score(product: Product, vibeTags: Set<String>) -> Double {
        let inferredTags = tagInferer.inferTags(for: product)
        let matchCount = Double(inferredTags.intersection(vibeTags).count)
        let ratingBoost = product.rating ?? 0
        return matchCount * 2 + ratingBoost
    }
}
