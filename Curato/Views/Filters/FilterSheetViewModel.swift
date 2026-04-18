import Combine
import Foundation

@MainActor
final class FilterSheetViewModel: ObservableObject {
    enum StyleFrame: String, CaseIterable, Identifiable {
        case any = "Any"
        case masculine = "Masculine"
        case feminine = "Feminine"
        case androgynous = "Androgynous"

        var id: String { rawValue }
    }

    struct BudgetPreset: Identifiable {
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

    let categorySuggestions = ["Tops", "Pants", "Shoes", "Outerwear", "Accessories"]
    let budgetPresets: [BudgetPreset] = [
        .init(id: "under50", label: "Under $50", min: nil, max: 50, sliderValue: 0),
        .init(id: "under100", label: "Under $100", min: nil, max: 100, sliderValue: 1),
        .init(id: "under150", label: "Under $150", min: nil, max: 150, sliderValue: 2),
        .init(id: "nolimit", label: "No limit", min: nil, max: nil, sliderValue: 3)
    ]

    @Published var workingOptions: FilterOptions
    @Published var selectedStyleFrame: StyleFrame
    @Published var selectedBudgetSliderValue: Double

    init(initialOptions: FilterOptions) {
        self.workingOptions = initialOptions
        self.selectedStyleFrame = Self.inferStyleFrame(from: initialOptions.vibeText)
        self.selectedBudgetSliderValue = Self.sliderValue(for: initialOptions.budgetMax)
    }

    var selectedBudgetPreset: BudgetPreset {
        let index = min(max(Int(selectedBudgetSliderValue.rounded()), 0), budgetPresets.count - 1)
        return budgetPresets[index]
    }

    var appliedOptions: FilterOptions {
        var options = workingOptions
        let budgetPreset = selectedBudgetPreset
        options.budgetMin = budgetPreset.min
        options.budgetMax = budgetPreset.max
        options.vibeText = styledVibeText(baseText: options.vibeText, styleFrame: selectedStyleFrame)
        return options
    }

    func toggleCategory(_ category: String) {
        if workingOptions.selectedCategories.contains(category) {
            workingOptions.selectedCategories.remove(category)
        } else {
            workingOptions.selectedCategories.insert(category)
        }
    }

    func applyVibeSuggestion(_ vibe: String) {
        let base = workingOptions.vibeText.trimmingCharacters(in: .whitespacesAndNewlines)
        if base.isEmpty {
            workingOptions.vibeText = vibe
            return
        }

        let existing = Set(
            base
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        )

        if existing.contains(vibe.lowercased()) {
            workingOptions.vibeText = base
            return
        }

        workingOptions.vibeText = "\(base), \(vibe)"
    }

    func clear() {
        workingOptions = FilterOptions()
        selectedStyleFrame = .any
        selectedBudgetSliderValue = 3
    }

    private func styledVibeText(baseText: String, styleFrame: StyleFrame) -> String {
        let trimmed = baseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard styleFrame != .any else { return trimmed }

        let lowercased = trimmed.lowercased()
        let styleToken = styleFrame.rawValue.lowercased()

        if lowercased.contains(styleToken) {
            return trimmed
        }

        if trimmed.isEmpty {
            return styleToken
        }

        return "\(trimmed), \(styleToken)"
    }

    private static func sliderValue(for budgetMax: Double?) -> Double {
        guard let budgetMax else { return 3 }
        if budgetMax <= 50 { return 0 }
        if budgetMax <= 100 { return 1 }
        if budgetMax <= 150 { return 2 }
        return 3
    }

    private static func inferStyleFrame(from vibeText: String) -> StyleFrame {
        let normalized = vibeText.lowercased()
        if normalized.contains("androgynous") { return .androgynous }
        if normalized.contains("feminine") { return .feminine }
        if normalized.contains("masculine") { return .masculine }
        return .any
    }
}
