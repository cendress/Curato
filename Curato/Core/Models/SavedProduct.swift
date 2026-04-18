import Foundation
import SwiftData

@Model
final class SavedProduct {
    @Attribute(.unique) var id: String
    var title: String
    var merchant: String
    var price: Double?
    var originalPrice: Double?
    var rating: Double?
    var reviewCount: Int?
    var imageURL: String?
    var productURL: String?
    var reasonText: String?
    var tags: [String]
    var category: String?
    var savedAt: Date

    init(
        id: String,
        title: String,
        merchant: String,
        price: Double? = nil,
        originalPrice: Double? = nil,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        imageURL: String? = nil,
        productURL: String? = nil,
        reasonText: String? = nil,
        tags: [String] = [],
        category: String? = nil,
        savedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.merchant = merchant
        self.price = price
        self.originalPrice = originalPrice
        self.rating = rating
        self.reviewCount = reviewCount
        self.imageURL = imageURL
        self.productURL = productURL
        self.reasonText = reasonText
        self.tags = tags
        self.category = category
        self.savedAt = savedAt
    }
}

extension SavedProduct {
    var asProduct: Product {
        Product(
            id: id,
            title: title,
            merchant: merchant,
            price: price,
            originalPrice: originalPrice,
            rating: rating,
            reviewCount: reviewCount,
            imageURL: imageURL,
            thumbnailURLs: imageURL.map { [$0] } ?? [],
            productURL: productURL,
            reasonText: reasonText,
            tags: tags,
            category: category
        )
    }

    static func from(product: Product) -> SavedProduct {
        SavedProduct(
            id: product.id,
            title: product.title,
            merchant: product.merchant,
            price: product.price,
            originalPrice: product.originalPrice,
            rating: product.rating,
            reviewCount: product.reviewCount,
            imageURL: product.imageURL,
            productURL: product.productURL,
            reasonText: product.reasonText,
            tags: product.tags,
            category: product.category,
            savedAt: .now
        )
    }
}
