import Combine
import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published private(set) var deck: [Product] = []
    @Published var isLoading = false
    @Published var filterOptions: FilterOptions

    private let apiClient: SerpAPIClient
    private let recommendationEngine: Recommending

    init(
        filterOptions: FilterOptions? = nil,
        apiClient: SerpAPIClient? = nil,
        recommendationEngine: Recommending? = nil
    ) {
        self.filterOptions = filterOptions ?? FilterOptions()
        self.apiClient = apiClient ?? PlaceholderSerpAPIClient()
        self.recommendationEngine = recommendationEngine ?? RecommendationEngine()
    }

    var currentProduct: Product? {
        deck.first
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await apiClient.searchProducts(
                query: filterOptions.vibeText.isEmpty ? "curated shopping" : filterOptions.vibeText,
                location: filterOptions.location,
                limit: 20
            )

            let seed = fetched.isEmpty ? Product.mockDeck : fetched
            deck = recommendationEngine.rank(products: seed, for: filterOptions)

            if deck.isEmpty {
                deck = Product.mockDeck
            }
        } catch {
            deck = Product.mockDeck
        }
    }

    func applyFilters(_ options: FilterOptions) {
        filterOptions = options
    }

    func likeCurrent(profile: UserPreferenceProfile?) {
        guard let product = currentProduct else { return }
        profile?.likedProductIDs.append(product.id)
        adjustWeights(for: product, in: profile, isPositive: true)
        deck.removeFirst()
        Haptic.light()
    }

    func skipCurrent(profile: UserPreferenceProfile?) {
        guard let product = currentProduct else { return }
        profile?.skippedProductIDs.append(product.id)
        adjustWeights(for: product, in: profile, isPositive: false)
        deck.removeFirst()
        Haptic.selection()
    }

    private func adjustWeights(for product: Product, in profile: UserPreferenceProfile?, isPositive: Bool) {
        guard let profile else { return }

        for tag in product.tags {
            if isPositive {
                profile.positiveTagWeights[tag, default: 0] += 1
            } else {
                profile.negativeTagWeights[tag, default: 0] += 1
            }
        }
    }
}
