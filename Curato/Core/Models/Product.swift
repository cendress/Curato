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
    let productURL: String?
    let reasonText: String?
    let tags: [String]
    let category: String?
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
