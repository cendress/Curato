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
}
