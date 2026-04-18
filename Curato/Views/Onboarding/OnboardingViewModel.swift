import Combine
import Foundation
import SwiftData

@MainActor
final class OnboardingViewModel: ObservableObject {
    enum Step: Int, CaseIterable {
        case welcome
        case vibeIntent
        case preferences

        var ctaTitle: String {
            switch self {
            case .welcome:
                return "Get started"
            case .vibeIntent:
                return "Continue"
            case .preferences:
                return "Show my feed"
            }
        }
    }

    enum StyleFrame: String, CaseIterable, Identifiable {
        case any = "Any"
        case masculine = "Masculine"
        case feminine = "Feminine"
        case androgynous = "Androgynous"

        var id: String { rawValue }
    }

    struct BudgetPreset: Identifiable, Hashable {
        let id: String
        let label: String
        let min: Double?
        let max: Double?
        let sliderValue: Double
    }

    let vibeSuggestions = [
        "Minimal",
        "Streetwear",
        "Date Night",
        "Clean Basics",
        "Office",
        "Summer",
        "Soft Masculine",
        "Vintage"
    ]

    let budgetPresets: [BudgetPreset] = [
        .init(id: "under50", label: "Under $50", min: nil, max: 50, sliderValue: 0),
        .init(id: "under100", label: "Under $100", min: nil, max: 100, sliderValue: 1),
        .init(id: "under150", label: "Under $150", min: nil, max: 150, sliderValue: 2),
        .init(id: "nolimit", label: "No limit", min: nil, max: nil, sliderValue: 3)
    ]

    let categorySuggestions = ["Tops", "Pants", "Shoes", "Outerwear", "Accessories"]

    @Published private(set) var currentStep: Step = .welcome
    @Published var selectedVibes: Set<String> = []
    @Published var customIntentText: String = ""
    @Published var selectedBudgetSliderValue: Double = 1
    @Published var selectedCategories: Set<String> = []
    @Published var selectedStyleFrame: StyleFrame = .any
    @Published var location: String = ""
    @Published private(set) var isSaving = false

    init(session: AppSessionState? = nil) {
        if let session {
            customIntentText = session.activeVibeText
            selectedCategories = Set(session.selectedCategories)
            location = session.activeLocation ?? ""
            selectedBudgetSliderValue = Self.sliderValue(for: session.activeBudgetMax)
        }
    }

    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(Step.allCases.count)
    }

    var canContinue: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .vibeIntent:
            return !normalizedIntentText.isEmpty || !selectedVibes.isEmpty
        case .preferences:
            return true
        }
    }

    var selectedBudgetPreset: BudgetPreset {
        let index = min(max(Int(selectedBudgetSliderValue.rounded()), 0), budgetPresets.count - 1)
        return budgetPresets[index]
    }

    var summaryVibeText: String {
        var segments: [String] = []

        if !normalizedIntentText.isEmpty {
            segments.append(normalizedIntentText)
        }

        if !selectedVibes.isEmpty {
            segments.append(selectedVibes.sorted().joined(separator: ", "))
        }

        if selectedStyleFrame != .any {
            segments.append("\(selectedStyleFrame.rawValue) framing")
        }

        return segments.isEmpty ? "Curated recommendations" : segments.joined(separator: " • ")
    }

    func nextStep() {
        guard canContinue else { return }
        guard let next = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    func previousStep() {
        guard let previous = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previous
    }

    func toggleVibe(_ vibe: String) {
        if selectedVibes.contains(vibe) {
            selectedVibes.remove(vibe)
        } else {
            selectedVibes.insert(vibe)
        }
    }

    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    func selectBudgetPreset(_ preset: BudgetPreset) {
        selectedBudgetSliderValue = preset.sliderValue
    }

    func completeOnboarding(
        session: AppSessionState,
        profile: UserPreferenceProfile?,
        modelContext: ModelContext
    ) -> Bool {
        guard !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }

        applySelections(session: session, profile: profile)

        do {
            try modelContext.save()
            Haptic.success()
            return true
        } catch {
            assertionFailure("Failed to save onboarding state: \(error.localizedDescription)")
            return false
        }
    }

    func applySelections(session: AppSessionState, profile: UserPreferenceProfile?) {
        let budget = selectedBudgetPreset

        session.hasCompletedOnboarding = true
        session.activeVibeText = summaryVibeText
        session.activeBudgetMin = budget.min
        session.activeBudgetMax = budget.max
        session.selectedCategories = selectedCategories.sorted()
        session.activeLocation = normalizedLocation

        if let profile {
            profile.preferredBudgetMin = budget.min
            profile.preferredBudgetMax = budget.max
        }
    }

    private var normalizedIntentText: String {
        customIntentText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedLocation: String? {
        let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func sliderValue(for maxBudget: Double?) -> Double {
        guard let maxBudget else { return 3 }
        if maxBudget <= 50 { return 0 }
        if maxBudget <= 100 { return 1 }
        if maxBudget <= 150 { return 2 }
        return 3
    }
}
