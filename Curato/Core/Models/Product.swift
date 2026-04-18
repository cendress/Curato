import Foundation

struct Product: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let merchant: String
    let price: Double?
    let originalPrice: Double?
    let rating: Double?
    let reviewCount: Int?
    let imageURL: String?
    let thumbnailURLs: [String]
    let productURL: String?
    let queryUsed: String?
    let snippet: String?
    let reasonText: String?
    let tags: [String]
    let category: String?

    init(
        id: String,
        title: String,
        merchant: String,
        price: Double? = nil,
        originalPrice: Double? = nil,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        imageURL: String? = nil,
        thumbnailURLs: [String] = [],
        productURL: String? = nil,
        queryUsed: String? = nil,
        snippet: String? = nil,
        reasonText: String? = nil,
        tags: [String] = [],
        category: String? = nil
    ) {
        self.id = id
        self.title = title
        self.merchant = merchant
        self.price = price
        self.originalPrice = originalPrice
        self.rating = rating
        self.reviewCount = reviewCount
        self.imageURL = imageURL
        self.thumbnailURLs = thumbnailURLs
        self.productURL = productURL
        self.queryUsed = queryUsed
        self.snippet = snippet
        self.reasonText = reasonText
        self.tags = tags
        self.category = category
    }
}

extension Product {
    static let mockDeck: [Product] = [
        Product(
            id: "mock-1",
            title: "Minimal Leather Weekender",
            merchant: "Nordhaven",
            price: 189,
            originalPrice: 245,
            rating: 4.7,
            reviewCount: 280,
            imageURL: nil,
            productURL: nil,
            reasonText: "Matches your clean, travel-friendly vibe.",
            tags: ["minimal", "travel", "premium"],
            category: "Bags"
        ),
        Product(
            id: "mock-2",
            title: "Lightweight City Sneaker",
            merchant: "Arcline",
            price: 124,
            originalPrice: nil,
            rating: 4.5,
            reviewCount: 1021,
            imageURL: nil,
            productURL: nil,
            reasonText: "Great value inside your budget range.",
            tags: ["casual", "streetwear", "comfort"],
            category: "Shoes"
        ),
        Product(
            id: "mock-3",
            title: "Studio Knit Polo",
            merchant: "Alder & Co.",
            price: 74,
            originalPrice: 98,
            rating: 4.4,
            reviewCount: 412,
            imageURL: nil,
            productURL: nil,
            reasonText: "Popular in the smart-casual category.",
            tags: ["smart-casual", "summer"],
            category: "Tops"
        )
    ]
}
