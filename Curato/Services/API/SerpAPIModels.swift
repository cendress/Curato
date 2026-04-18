import Foundation

struct SerpSearchResponse: Codable {
    let shoppingResults: [SerpShoppingResult]

    enum CodingKeys: String, CodingKey {
        case shoppingResults = "shopping_results"
    }
}

struct SerpShoppingResult: Codable, Hashable {
    let productID: String
    let title: String
    let source: String
    let price: Double?
    let oldPrice: Double?
    let rating: Double?
    let reviews: Int?
    let thumbnail: String?
    let productLink: String?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case title
        case source
        case price
        case oldPrice = "old_price"
        case rating
        case reviews
        case thumbnail
        case productLink = "product_link"
    }
}

extension SerpSearchResponse {
    static let placeholder = SerpSearchResponse(
        shoppingResults: [
            SerpShoppingResult(
                productID: "serp-mock-1",
                title: "Everyday Selvedge Denim Jacket",
                source: "Northrow",
                price: 145,
                oldPrice: 180,
                rating: 4.6,
                reviews: 522,
                thumbnail: nil,
                productLink: nil
            ),
            SerpShoppingResult(
                productID: "serp-mock-2",
                title: "Performance Trail Runner",
                source: "Horizon",
                price: 98,
                oldPrice: nil,
                rating: 4.3,
                reviews: 204,
                thumbnail: nil,
                productLink: nil
            )
        ]
    )
}
