import Foundation

protocol SerpAPIProductMapping {
    func map(response: SerpSearchResponse) -> [Product]
}

struct SerpAPIMapper: SerpAPIProductMapping {
    func map(response: SerpSearchResponse) -> [Product] {
        response.shoppingResults.map {
            Product(
                id: $0.productID,
                title: $0.title,
                merchant: $0.source,
                price: $0.price,
                originalPrice: $0.oldPrice,
                rating: $0.rating,
                reviewCount: $0.reviews,
                imageURL: $0.thumbnail,
                productURL: $0.productLink,
                reasonText: "Matched from your current vibe and budget.",
                tags: [],
                category: nil
            )
        }
    }
}
