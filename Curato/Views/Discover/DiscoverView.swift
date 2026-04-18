import SwiftData
import SwiftUI

struct DiscoverView: View {
    let session: AppSessionState

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserPreferenceProfile]

    @StateObject private var viewModel = DiscoverViewModel()
    @State private var selectedProduct: Product?
    @State private var isShowingFilterSheet = false

    private var profile: UserPreferenceProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DeckHeaderView(vibeText: session.activeVibeText, onTapFilter: {
                    isShowingFilterSheet = true
                })

                if viewModel.isLoading {
                    Spacer()
                    LoadingView(title: "Loading your next picks...")
                    Spacer()
                } else if let current = viewModel.currentProduct {
                    SwipeDeckView(
                        product: current,
                        onLike: {
                            viewModel.likeCurrent(profile: profile)
                            saveContext()
                        },
                        onSkip: {
                            viewModel.skipCurrent(profile: profile)
                            saveContext()
                        },
                        onInfo: {
                            selectedProduct = current
                        }
                    )

                    SwipeActionButtons(
                        onSkip: {
                            viewModel.skipCurrent(profile: profile)
                            saveContext()
                        },
                        onLike: {
                            viewModel.likeCurrent(profile: profile)
                            saveContext()
                        },
                        onInfo: {
                            selectedProduct = current
                        }
                    )
                } else {
                    Spacer()
                    EmptyStateView(
                        iconName: "rectangle.stack.badge.person.crop",
                        title: "You reached the end of the deck",
                        subtitle: "Refresh to generate more personalized product cards.",
                        actionTitle: "Refresh"
                    ) {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.appBackground)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            FilterSheetView(initialOptions: viewModel.filterOptions) { newOptions in
                session.activeVibeText = newOptions.vibeText
                session.activeBudgetMin = newOptions.budgetMin
                session.activeBudgetMax = newOptions.budgetMax
                session.selectedCategories = newOptions.selectedCategories.sorted()
                session.activeLocation = newOptions.location

                viewModel.applyFilters(newOptions)
                saveContext()

                Task {
                    await viewModel.loadProducts()
                }
            }
        }
        .task {
            if viewModel.currentProduct == nil {
                viewModel.applyFilters(
                    FilterOptions(
                        vibeText: session.activeVibeText,
                        budgetMin: session.activeBudgetMin,
                        budgetMax: session.activeBudgetMax,
                        selectedCategories: Set(session.selectedCategories),
                        location: session.activeLocation
                    )
                )
                await viewModel.loadProducts()
            }
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save discover state: \(error.localizedDescription)")
        }
    }
}

#Preview {
    DiscoverView(session: AppSessionState(hasCompletedOnboarding: true, activeVibeText: "Minimal + clean"))
        .modelContainer(SwiftDataContainer.preview)
}
