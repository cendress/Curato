import Foundation

protocol ProductTagInferring {
    func inferProductTags(product: Product) -> [String]
}

struct ProductTagInferer: ProductTagInferring {
    func inferProductTags(product: Product) -> [String] {
        var tags: [String] = []

        product.tags
            .map(normalize)
            .filter { !$0.isEmpty }
            .forEach { appendUnique($0, to: &tags) }

        if let category = product.category {
            appendUnique(normalize(category), to: &tags)
        }

        let textBlob = [
            product.title,
            product.snippet ?? "",
            product.merchant,
            product.category ?? ""
        ].joined(separator: " ")

        tokenize(textBlob)
            .filter { $0.count > 2 }
            .forEach { appendUnique($0, to: &tags) }

        for (trigger, mappedTag) in styleSignalMap {
            if textBlob.lowercased().contains(trigger) {
                appendUnique(mappedTag, to: &tags)
            }
        }

        for (trigger, mappedCategory) in categorySignalMap {
            if textBlob.lowercased().contains(trigger) {
                appendUnique(mappedCategory, to: &tags)
            }
        }

        return tags
    }

    private let styleSignalMap: [String: String] = [
        "minimal": "minimal",
        "vintage": "vintage",
        "street": "streetwear",
        "office": "office",
        "date": "date-night",
        "basic": "basics",
        "summer": "summer",
        "soft": "soft-style",
        "masculine": "masculine"
    ]

    private let categorySignalMap: [String: String] = [
        "shirt": "tops",
        "tee": "tops",
        "blouse": "tops",
        "jean": "pants",
        "trouser": "pants",
        "sneaker": "shoes",
        "boot": "shoes",
        "jacket": "outerwear",
        "coat": "outerwear",
        "bag": "accessories",
        "belt": "accessories",
        "watch": "accessories"
    ]

    private func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map(normalize)
            .filter { !$0.isEmpty }
    }

    private func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func appendUnique(_ value: String, to array: inout [String]) {
        guard !array.contains(value) else { return }
        array.append(value)
    }
}
