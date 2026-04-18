import Combine
import Foundation
import SwiftData

@MainActor
final class OnboardingViewModel: ObservableObject {
    struct BudgetPreset: Identifiable, Hashable {
        let id: String
        let label: String
        let min: Double?
        let max: Double?
    }

    let vibeSuggestions = [
        "Minimal + clean",
        "Streetwear + bold",
        "Luxury basics",
        "Outdoor + functional",
        "Vintage + eclectic"
    ]

    let budgetPresets: [BudgetPreset] = [
        .init(id: "any", label: "Any budget", min: nil, max: nil),
        .init(id: "under100", label: "Under $100", min: nil, max: 100),
        .init(id: "100to250", label: "$100 - $250", min: 100, max: 250),
        .init(id: "250plus", label: "$250+", min: 250, max: nil)
    ]

    let categorySuggestions = ["Tops", "Shoes", "Bags", "Accessories", "Home", "Beauty"]

    @Published var selectedVibe: String = ""
    @Published var selectedBudgetID: String = "any"
    @Published var selectedCategories: Set<String> = []
    @Published var location: String = ""

    var selectedBudgetPreset: BudgetPreset {
        budgetPresets.first(where: { $0.id == selectedBudgetID }) ?? budgetPresets[0]
    }

    func completeOnboarding(
        session: AppSessionState,
        profile: UserPreferenceProfile?,
        modelContext: ModelContext
    ) {
        let budget = selectedBudgetPreset

        session.hasCompletedOnboarding = true
        session.activeVibeText = selectedVibe
        session.activeBudgetMin = budget.min
        session.activeBudgetMax = budget.max
        session.selectedCategories = selectedCategories.sorted()
        session.activeLocation = location.isEmpty ? nil : location

        if let profile {
            profile.preferredBudgetMin = budget.min
            profile.preferredBudgetMax = budget.max
        }

        do {
            try modelContext.save()
            Haptic.success()
        } catch {
            assertionFailure("Failed to save onboarding state: \(error.localizedDescription)")
        }
    }
}
