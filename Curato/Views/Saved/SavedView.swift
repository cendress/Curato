import SwiftData
import SwiftUI

struct SavedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedProduct.savedAt, order: .reverse) private var savedProducts: [SavedProduct]

    @StateObject private var viewModel = SavedViewModel()
    @State private var selectedProduct: Product?

    var body: some View {
        NavigationStack {
            Group {
                if savedProducts.isEmpty {
                    EmptySavedStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(savedProducts) { product in
                                Button {
                                    selectedProduct = product.asProduct
                                } label: {
                                    SavedItemCard(
                                        product: product,
                                        savedDateText: viewModel.dateLabel(for: product.savedAt)
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.delete(product, from: modelContext)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Saved")
            .background(Color.appBackground)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
}

#Preview {
    SavedView()
        .modelContainer(SwiftDataContainer.preview)
}
