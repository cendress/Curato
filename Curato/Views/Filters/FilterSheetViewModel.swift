import Combine
import Foundation

@MainActor
final class FilterSheetViewModel: ObservableObject {
    let vibeSuggestions = [
        "Minimal + clean",
        "Streetwear + bold",
        "Luxury basics",
        "Outdoor + functional",
        "Vintage + eclectic"
    ]

    let categorySuggestions = ["Tops", "Shoes", "Bags", "Accessories", "Home", "Beauty"]

    @Published var workingOptions: FilterOptions

    init(initialOptions: FilterOptions) {
        self.workingOptions = initialOptions
    }

    func toggleCategory(_ category: String) {
        if workingOptions.selectedCategories.contains(category) {
            workingOptions.selectedCategories.remove(category)
        } else {
            workingOptions.selectedCategories.insert(category)
        }
    }

    func clear() {
        workingOptions = FilterOptions()
    }
}
