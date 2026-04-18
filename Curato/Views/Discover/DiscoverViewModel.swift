import Combine
import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published private(set) var originalProducts: [Product] = []
    @Published private(set) var rankedProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filterOptions: FilterOptions

    private let apiClient: SerpAPIClient
    private let recommendationEngine: Recommending
    private let gl: String
    private let hl: String

    init(
        filterOptions: FilterOptions? = nil,
        apiClient: SerpAPIClient? = nil,
        recommendationEngine: Recommending? = nil,
        gl: String = "us",
        hl: String = "en"
    ) {
        self.filterOptions = filterOptions ?? FilterOptions()
        self.apiClient = apiClient ?? LiveSerpAPIClient()
        self.recommendationEngine = recommendationEngine ?? RecommendationEngine()
        self.gl = gl
        self.hl = hl
    }

    var currentProduct: Product? {
        rankedProducts.first
    }

    func configureFromSession(_ session: AppSessionState) {
        filterOptions = FilterOptions(
            vibeText: session.activeVibeText,
            budgetMin: session.activeBudgetMin,
            budgetMax: session.activeBudgetMax,
            selectedCategories: Set(session.selectedCategories),
            location: session.activeLocation
        )
    }

    func loadProducts(session: AppSessionState, profile: UserPreferenceProfile?) async {
        configureFromSession(session)
        await loadProducts(profile: profile)
    }

    func loadProducts(profile: UserPreferenceProfile?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched = try await apiClient.searchProducts(
                vibeText: filterOptions.vibeText,
                categories: filterOptions.selectedCategories.sorted(),
                budgetMin: filterOptions.budgetMin,
                budgetMax: filterOptions.budgetMax,
                location: resolvedLocation,
                gl: gl,
                hl: hl
            )

            originalProducts = fetched
            rerankProducts(profile: profile)

            if rankedProducts.isEmpty {
                errorMessage = "No products matched your current preferences. Try broadening your filters."
            }
        } catch let error as SerpAPIClientError {
            originalProducts = []
            rankedProducts = []
            errorMessage = error.errorDescription
        } catch {
            originalProducts = []
            rankedProducts = []
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }

    func applyFilters(_ options: FilterOptions, profile: UserPreferenceProfile?) {
        filterOptions = options
        rerankProducts(profile: profile)
    }

    func likeCurrent(profile: UserPreferenceProfile?) {
        guard let product = currentProduct else { return }
        profile?.registerLike(product: product)
        rerankProducts(profile: profile)
        Haptic.light()
    }

    func skipCurrent(profile: UserPreferenceProfile?) {
        guard let product = currentProduct else { return }
        profile?.registerSkip(product: product)
        rerankProducts(profile: profile)
        Haptic.selection()
    }

    func registerSave(_ product: Product, profile: UserPreferenceProfile?) {
        profile?.registerSave(product: product)
        rerankProducts(profile: profile)
    }

    private var resolvedLocation: String {
        let trimmed = filterOptions.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "United States" : trimmed
    }

    private func rerankProducts(profile: UserPreferenceProfile?) {
        let seenIDs = Set((profile?.likedProductIDs ?? []) + (profile?.skippedProductIDs ?? []) + (profile?.savedProductIDs ?? []))
        let candidates = originalProducts.filter { !seenIDs.contains($0.id) }

        rankedProducts = recommendationEngine.rerankProducts(
            products: candidates,
            profile: profile,
            vibeText: filterOptions.vibeText,
            selectedCategories: filterOptions.selectedCategories.sorted(),
            budgetMin: filterOptions.budgetMin,
            budgetMax: filterOptions.budgetMax
        )
    }
}
