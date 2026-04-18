import Foundation

protocol ProductTagInferring {
    func inferTags(for product: Product) -> Set<String>
}

struct ProductTagInferer: ProductTagInferring {
    func inferTags(for product: Product) -> Set<String> {
        var tags = Set(product.tags.map { $0.lowercased() })

        if let category = product.category?.lowercased() {
            tags.insert(category)
        }

        tags.formUnion(
            product.title
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { $0.count > 3 }
        )

        return tags
    }
}
