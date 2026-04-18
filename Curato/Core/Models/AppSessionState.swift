import Foundation
import SwiftData

@Model
final class AppSessionState {
    @Attribute(.unique) var id: UUID
    var hasCompletedOnboarding: Bool
    var activeVibeText: String
    var activeBudgetMin: Double?
    var activeBudgetMax: Double?
    var selectedCategories: [String]
    var activeLocation: String?

    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        activeVibeText: String = "",
        activeBudgetMin: Double? = nil,
        activeBudgetMax: Double? = nil,
        selectedCategories: [String] = [],
        activeLocation: String? = nil
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.activeVibeText = activeVibeText
        self.activeBudgetMin = activeBudgetMin
        self.activeBudgetMax = activeBudgetMax
        self.selectedCategories = selectedCategories
        self.activeLocation = activeLocation
    }
}
