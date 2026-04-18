import Foundation
import SwiftData

@Model
final class UserPreferenceProfile {
    @Attribute(.unique) var id: UUID
    var positiveTagWeights: [String: Double]
    var negativeTagWeights: [String: Double]
    var likedProductIDs: [String]
    var skippedProductIDs: [String]
    var savedProductIDs: [String]
    var preferredBudgetMin: Double?
    var preferredBudgetMax: Double?

    init(
        id: UUID = UUID(),
        positiveTagWeights: [String: Double] = [:],
        negativeTagWeights: [String: Double] = [:],
        likedProductIDs: [String] = [],
        skippedProductIDs: [String] = [],
        savedProductIDs: [String] = [],
        preferredBudgetMin: Double? = nil,
        preferredBudgetMax: Double? = nil
    ) {
        self.id = id
        self.positiveTagWeights = positiveTagWeights
        self.negativeTagWeights = negativeTagWeights
        self.likedProductIDs = likedProductIDs
        self.skippedProductIDs = skippedProductIDs
        self.savedProductIDs = savedProductIDs
        self.preferredBudgetMin = preferredBudgetMin
        self.preferredBudgetMax = preferredBudgetMax
    }

    func registerLike(product: Product) {
        appendUnique(product.id, to: &likedProductIDs)
        skippedProductIDs.removeAll { $0 == product.id }
        applyWeightDelta(for: product, positiveDelta: 1.1, negativeDelta: -0.2)
    }

    func registerSkip(product: Product) {
        appendUnique(product.id, to: &skippedProductIDs)
        likedProductIDs.removeAll { $0 == product.id }
        applyWeightDelta(for: product, positiveDelta: -0.15, negativeDelta: 0.95)
    }

    func registerSave(product: Product) {
        appendUnique(product.id, to: &savedProductIDs)
        applyWeightDelta(for: product, positiveDelta: 0.8, negativeDelta: -0.1)
    }

    private func applyWeightDelta(
        for product: Product,
        positiveDelta: Double,
        negativeDelta: Double
    ) {
        for tag in interactionTags(for: product) {
            positiveTagWeights[tag, default: 0] = max(0, positiveTagWeights[tag, default: 0] + positiveDelta)
            negativeTagWeights[tag, default: 0] = max(0, negativeTagWeights[tag, default: 0] + negativeDelta)
        }
    }

    private func interactionTags(for product: Product) -> Set<String> {
        var tags = Set(product.tags.map(Self.normalizeTag))

        if let category = product.category {
            tags.insert(Self.normalizeTag(category))
        }

        tags.formUnion(Self.tokenize(product.title))
        tags.formUnion(Self.tokenize(product.merchant))
        tags.formUnion(Self.tokenize(product.snippet))

        return tags.filter { !$0.isEmpty }
    }

    private func appendUnique(_ id: String, to collection: inout [String]) {
        guard !collection.contains(id) else { return }
        collection.append(id)
    }

    private static func tokenize(_ text: String?) -> Set<String> {
        guard let text, !text.isEmpty else { return [] }
        let parts = text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map(normalizeTag)
            .filter { $0.count > 2 }
        return Set(parts)
    }

    private static func normalizeTag(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
