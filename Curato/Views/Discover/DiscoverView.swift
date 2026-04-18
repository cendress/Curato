import SwiftData
import SwiftUI

struct DiscoverView: View {
    let session: AppSessionState

    @Environment(\.modelContext) private var modelContext
    @Query private var savedProducts: [SavedProduct]
    @Query private var profiles: [UserPreferenceProfile]

    @StateObject private var viewModel = DiscoverViewModel()
    @State private var selectedProduct: Product?
    @State private var isShowingFilterSheet = false

    private var profile: UserPreferenceProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appSurface.opacity(0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        Spacer()
                        LoadingView(title: "Loading live shopping results...")
                        Spacer()
                    } else if let current = viewModel.currentProduct {
                        SwipeDeckView(
                            product: current,
                            onPass: {
                                viewModel.skipCurrent(profile: profile)
                                saveContext()
                            },
                            onSave: {
                                guard let productToSave = viewModel.currentProduct else { return }
                                persistSave(productToSave)
                            },
                            onLike: {
                                viewModel.likeCurrent(profile: profile)
                                saveContext()
                            },
                            onOpenDetail: {
                                selectedProduct = current
                            }
                        )
                    } else {
                        Spacer()
                        EmptyStateView(
                            iconName: viewModel.errorMessage == nil ? "rectangle.stack.badge.person.crop" : "exclamationmark.triangle",
                            title: viewModel.errorMessage == nil ? "You reached the end of the deck" : "Couldn't load products",
                            subtitle: viewModel.errorMessage ?? "Refresh to load more personalized product cards.",
                            actionTitle: "Refresh"
                        ) {
                            Task {
                                await viewModel.loadProducts(session: session, profile: profile)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingFilterSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Refine feed")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(
                product: product,
                onSaveStateChange: { _, _ in
                    viewModel.refreshRanking(profile: profile)
                },
                onLike: { _ in
                    viewModel.refreshRanking(profile: profile)
                }
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            FilterSheetView(initialOptions: viewModel.filterOptions) { newOptions in
                session.activeVibeText = newOptions.vibeText
                session.activeBudgetMin = newOptions.budgetMin
                session.activeBudgetMax = newOptions.budgetMax
                session.selectedCategories = newOptions.selectedCategories.sorted()
                session.activeLocation = newOptions.location

                viewModel.applyFilters(newOptions, profile: profile)
                saveContext()

                Task {
                    await viewModel.loadProducts(session: session, profile: profile)
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .task {
            if viewModel.currentProduct == nil, !viewModel.isLoading {
                await viewModel.loadProducts(session: session, profile: profile)
            }
        }
    }

    private func persistSave(_ product: Product) {
        guard !isSaved(productID: product.id) else {
            viewModel.refreshRanking(profile: profile)
            return
        }

        modelContext.insert(SavedProduct.from(product: product))
        viewModel.registerSave(product, profile: profile)
        saveContext()
    }

    private func isSaved(productID: String) -> Bool {
        savedProducts.contains(where: { $0.id == productID })
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
