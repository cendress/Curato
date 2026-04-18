import SwiftData
import SwiftUI

struct ProductDetailView: View {
    let product: Product

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserPreferenceProfile]

    @State private var saveMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImageView(urlString: product.imageURL, height: 300)

                    Text(product.merchant)
                        .font(AppTypography.productBrand)
                        .foregroundStyle(.secondary)

                    Text(product.title)
                        .font(AppTypography.sectionHeaderLarge)

                    Text(PriceFormatter.string(from: product.price))
                        .font(AppTypography.productPrice)

                    if let reason = product.reasonText {
                        Text(reason)
                            .font(AppTypography.recommendationReason)
                            .foregroundStyle(.secondary)
                    }

                    if !product.tags.isEmpty {
                        FlowTagList(tags: product.tags)
                    }

                    if let saveMessage {
                        Text(saveMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProduct()
                    }
                    .font(AppTypography.navigationLabel)
                }
            }
        }
    }

    private func saveProduct() {
        let descriptor = FetchDescriptor<SavedProduct>(
            predicate: #Predicate<SavedProduct> { $0.id == product.id }
        )

        if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
            saveMessage = "Already in Saved"
            return
        }

        modelContext.insert(SavedProduct.from(product: product))

        if let profile = profiles.first, !profile.savedProductIDs.contains(product.id) {
            profile.savedProductIDs.append(product.id)
        }

        do {
            try modelContext.save()
            Haptic.success()
            saveMessage = "Saved to your collection"
        } catch {
            saveMessage = "Failed to save. Try again."
        }
    }
}

private struct FlowTagList: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 8)], spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag.capitalized)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.appSurface))
            }
        }
    }
}

#Preview {
    ProductDetailView(product: Product.mockDeck[0])
        .modelContainer(SwiftDataContainer.preview)
}
