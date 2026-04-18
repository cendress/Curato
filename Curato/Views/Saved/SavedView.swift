import SwiftData
import SwiftUI

struct SavedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedProduct.savedAt, order: .reverse) private var savedProducts: [SavedProduct]
    @Query private var profiles: [UserPreferenceProfile]

    @StateObject private var viewModel = SavedViewModel()
    @State private var selectedProduct: Product?
    @State private var isShowingClearConfirmation = false

    private var profile: UserPreferenceProfile? {
        profiles.first
    }

    private var displayedProducts: [SavedProduct] {
        viewModel.sortedProducts(savedProducts)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appSurface.opacity(0.48)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Group {
                    if savedProducts.isEmpty {
                        EmptySavedStateView()
                    } else {
                        VStack(spacing: 12) {
                            Picker("Sort", selection: $viewModel.sortOrder) {
                                ForEach(SavedViewModel.SavedSortOrder.allCases) { order in
                                    Text(order.title).tag(order)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)

                            List {
                                ForEach(displayedProducts) { product in
                                    Button {
                                        selectedProduct = product.asProduct
                                    } label: {
                                        SavedItemCard(
                                            product: product,
                                            savedDateText: viewModel.dateLabel(for: product.savedAt)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            withAnimation(.easeInOut(duration: 0.18)) {
                                                viewModel.delete(product, profile: profile, from: modelContext)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
            .navigationTitle("Saved")
            .toolbar {
                if !savedProducts.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear all", role: .destructive) {
                            isShowingClearConfirmation = true
                        }
                        .font(AppTypography.navigationLabel)
                    }
                }
            }
            .alert("Clear all saved items?", isPresented: $isShowingClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    viewModel.clearAll(savedProducts, profile: profile, from: modelContext)
                }
            } message: {
                Text("This removes all items from your saved list.")
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(
                product: product,
                onSaveStateChange: { _, isSaved in
                    if !isSaved {
                        selectedProduct = nil
                    }
                }
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
        }
    }
}

#Preview {
    SavedView()
        .modelContainer(SwiftDataContainer.preview)
}
