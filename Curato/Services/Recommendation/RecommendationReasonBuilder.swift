import Foundation

protocol RecommendationReasonBuilding {
    func buildReason(for product: Product, matchedTags: Set<String>) -> String
}

struct RecommendationReasonBuilder: RecommendationReasonBuilding {
    func buildReason(for product: Product, matchedTags: Set<String>) -> String {
        if let firstTag = matchedTags.sorted().first {
            return "Because you seem into \(firstTag)-leaning picks."
        }

        if let price = product.price {
            return "Curated near \(price.asCurrency) for your current budget."
        }

        return "Recommended based on your recent swipes."
    }
}
