import Foundation
import Testing
@testable import Curato

struct FormattingAndModelTests {
    @Test func priceFormatterHandlesNilAndValues() {
        #expect(PriceFormatter.string(from: nil) == "N/A")
        #expect(PriceFormatter.string(from: 49).contains("$"))
    }

    @Test func filterOptionsInitializeAsExpected() {
        let options = FilterOptions()
        #expect(options.vibeText.isEmpty)
        #expect(options.budgetMin == nil)
        #expect(options.budgetMax == nil)
        #expect(options.selectedCategories.isEmpty)
        #expect(options.location == nil)
    }
}

struct VibeParserTests {
    @Test func parseExtractsStyleSeasonAndBudgetSignals() {
        let parser = VibeParser()
        let tags = parser.parseVibeText("minimal spring outfits under 150")

        #expect(tags.contains("minimal"))
        #expect(tags.contains("spring"))
        #expect(tags.contains("outfit"))
        #expect(tags.contains("budget-conscious"))
        #expect(tags.contains("budget-under-150"))
    }
}

struct ProductTagInfererTests {
    @Test func inferIncludesSignalsFromTitleSnippetMerchantAndCategory() {
        let inferer = ProductTagInferer()
        let product = Product(
            id: "p-1",
            title: "Vintage denim jacket",
            merchant: "Retro Street",
            price: 98,
            snippet: "Soft streetwear look for summer evenings",
            tags: [],
            category: "Outerwear"
        )

        let tags = inferer.inferProductTags(product: product)

        #expect(tags.contains("vintage"))
        #expect(tags.contains("streetwear"))
        #expect(tags.contains("summer"))
        #expect(tags.contains("outerwear"))
    }
}

struct RecommendationReasonBuilderTests {
    @Test func reasonUsesStrongestSignals() {
        let builder = RecommendationReasonBuilder()
        let reason = builder.buildReason(
            explanation: RecommendationExplanation(
                matchedVibeTags: ["minimal"],
                matchedPreferenceTags: [],
                matchedCategory: nil,
                isWithinBudget: true,
                hasStrongRating: false
            )
        )

        #expect(reason.localizedCaseInsensitiveContains("minimal"))
        #expect(reason.localizedCaseInsensitiveContains("budget"))
    }

    @Test func reasonFallsBackWhenSignalsAreWeak() {
        let builder = RecommendationReasonBuilder()
        let reason = builder.buildReason(
            explanation: RecommendationExplanation(
                matchedVibeTags: [],
                matchedPreferenceTags: [],
                matchedCategory: nil,
                isWithinBudget: false,
                hasStrongRating: false
            )
        )

        #expect(reason == "Recommended because it matches your current shopping vibe.")
    }
}

struct RecommendationEngineTests {
    @Test func scoringAndRerankingPrioritizeVibeBudgetAndPreferences() {
        let engine = RecommendationEngine()

        let minimalSneaker = Product(
            id: "a",
            title: "Minimal white sneaker",
            merchant: "Atelier",
            price: 95,
            rating: 4.7,
            reviewCount: 900,
            snippet: "Clean basics for everyday wear",
            tags: ["minimal"],
            category: "Shoes"
        )

        let formalCoat = Product(
            id: "b",
            title: "Formal wool coat",
            merchant: "Tailor House",
            price: 280,
            rating: 4.0,
            reviewCount: 80,
            snippet: "Structured office staple",
            tags: ["formal"],
            category: "Outerwear"
        )

        let profile = UserPreferenceProfile(
            positiveTagWeights: ["minimal": 2.4],
            negativeTagWeights: ["formal": 1.3]
        )

        let scoreA = engine.scoreProduct(
            product: minimalSneaker,
            profile: profile,
            vibeTags: ["minimal"],
            selectedCategories: ["Shoes"],
            budgetMin: nil,
            budgetMax: 150
        )

        let scoreB = engine.scoreProduct(
            product: formalCoat,
            profile: profile,
            vibeTags: ["minimal"],
            selectedCategories: ["Shoes"],
            budgetMin: nil,
            budgetMax: 150
        )

        #expect(scoreA > scoreB)

        let reranked = engine.rerankProducts(
            products: [formalCoat, minimalSneaker],
            profile: profile,
            vibeText: "minimal sneakers under 150",
            selectedCategories: ["Shoes"],
            budgetMin: nil,
            budgetMax: 150
        )

        #expect(reranked.first?.id == "a")
        #expect((reranked.first?.reasonText?.isEmpty ?? true) == false)
    }
}

@MainActor
struct OnboardingSessionPersistenceTests {
    @Test func applySelectionsUpdatesSessionAndProfilePreferences() {
        let session = AppSessionState()
        let profile = UserPreferenceProfile()
        let viewModel = OnboardingViewModel(session: nil)

        viewModel.customIntentText = "Minimal spring outfits"
        viewModel.selectedVibes = ["Minimal", "Clean Basics"]
        viewModel.selectedCategories = ["Tops", "Shoes"]
        viewModel.selectedBudgetSliderValue = 2
        viewModel.location = "New York"

        viewModel.applySelections(session: session, profile: profile)

        #expect(session.hasCompletedOnboarding)
        #expect(session.activeVibeText.localizedCaseInsensitiveContains("minimal"))
        #expect(session.activeBudgetMax == 150)
        #expect(session.selectedCategories.contains("Tops"))
        #expect(session.activeLocation == "New York")

        #expect(profile.preferredBudgetMax == 150)
        #expect(profile.preferredBudgetMin == nil)
    }
}
