import Foundation

struct FilterOptions: Hashable {
    var vibeText: String
    var budgetMin: Double?
    var budgetMax: Double?
    var selectedCategories: Set<String>
    var location: String?

    init(
        vibeText: String = "",
        budgetMin: Double? = nil,
        budgetMax: Double? = nil,
        selectedCategories: Set<String> = [],
        location: String? = nil
    ) {
        self.vibeText = vibeText
        self.budgetMin = budgetMin
        self.budgetMax = budgetMax
        self.selectedCategories = selectedCategories
        self.location = location
    }
}
