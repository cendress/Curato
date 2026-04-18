import SwiftData
import SwiftUI

struct ProductDetailView: View {
    let product: Product
    var onSaveStateChange: ((Product, Bool) -> Void)? = nil
    var onLike: ((Product) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Query private var profiles: [UserPreferenceProfile]

    @State private var isSaved = false
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appSurface.opacity(0.52)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImageView(urlString: product.imageURL, height: 360)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(alignment: .topLeading) {
                                if isSaved {
                                    Label("Saved", systemImage: "bookmark.fill")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(Color.appAccent.opacity(0.92))
                                        )
                                        .padding(14)
                                }
                            }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(product.merchant)
                                .font(AppTypography.productBrand)
                                .foregroundStyle(.secondary)

                            Text(product.title)
                                .font(AppTypography.sectionHeaderLarge)
                                .multilineTextAlignment(.leading)

                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(PriceFormatter.string(from: product.price))
                                    .font(AppTypography.productPrice)

                                if let originalPrice = product.originalPrice,
                                   let currentPrice = product.price,
                                   originalPrice > currentPrice {
                                    Text(originalPrice.asCurrency)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .strikethrough()
                                }

                                Spacer()

                                if let rating = product.rating {
                                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.appAccent)
                                }
                            }

                            if let reason = product.reasonText {
                                Text(reason)
                                    .font(AppTypography.recommendationReason)
                                    .foregroundStyle(.secondary)
                            }

                            if !product.tags.isEmpty {
                                FlowTagList(tags: product.tags)
                            }

                            if let url = validatedProductURL {
                                Button {
                                    openURL(url)
                                } label: {
                                    Label("Open on web", systemImage: "arrow.up.right.square")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.appAccent)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(Color.white.opacity(0.9))
                                        )
                                }
                                .buttonStyle(.plain)
                            }

                            if let statusMessage {
                                Text(statusMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .padding(16)
                    .padding(.bottom, 110)
                }
            }
            .navigationTitle("Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(AppTypography.navigationLabel)
                }
            }
            .safeAreaInset(edge: .bottom) {
                actionBar
            }
        }
        .task {
            refreshSavedState()
        }
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            Button {
                toggleSaveState()
            } label: {
                Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                    .font(AppTypography.buttonText)
                    .foregroundStyle(isSaved ? Color.appAccent : Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.88))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSaved ? Color.appAccent.opacity(0.5) : Color.appBorder.opacity(0.35), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button {
                registerLike()
            } label: {
                Label("Like", systemImage: "heart.fill")
                    .font(AppTypography.buttonText)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AppButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
    }

    private var validatedProductURL: URL? {
        guard let productURL = product.productURL,
              let url = URL(string: productURL),
              let scheme = url.scheme,
              scheme.lowercased().hasPrefix("http") else {
            return nil
        }
        return url
    }

    private func toggleSaveState() {
        if isSaved {
            unsaveProduct()
        } else {
            saveProduct()
        }
    }

    private func saveProduct() {
        guard !isSaved else { return }

        let descriptor = FetchDescriptor<SavedProduct>(
            predicate: #Predicate<SavedProduct> { $0.id == product.id }
        )

        if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
            isSaved = true
            statusMessage = "Already in your saved collection"
            onSaveStateChange?(product, true)
            return
        }

        modelContext.insert(SavedProduct.from(product: product))
        profiles.first?.registerSave(product: product)

        do {
            try modelContext.save()
            isSaved = true
            statusMessage = "Saved to your collection"
            Haptic.success()
            onSaveStateChange?(product, true)
        } catch {
            statusMessage = "Failed to save. Try again."
        }
    }

    private func unsaveProduct() {
        let descriptor = FetchDescriptor<SavedProduct>(
            predicate: #Predicate<SavedProduct> { $0.id == product.id }
        )

        do {
            let existing = try modelContext.fetch(descriptor)
            for item in existing {
                modelContext.delete(item)
            }

            profiles.first?.unregisterSave(productID: product.id)
            try modelContext.save()

            isSaved = false
            statusMessage = "Removed from saved"
            Haptic.selection()
            onSaveStateChange?(product, false)
        } catch {
            statusMessage = "Failed to update saved state."
        }
    }

    private func registerLike() {
        profiles.first?.registerLike(product: product)

        do {
            try modelContext.save()
            statusMessage = "Added to your likes"
            Haptic.light()
            onLike?(product)
        } catch {
            statusMessage = "Failed to update likes."
        }
    }

    private func refreshSavedState() {
        let descriptor = FetchDescriptor<SavedProduct>(
            predicate: #Predicate<SavedProduct> { $0.id == product.id }
        )

        guard let existing = try? modelContext.fetch(descriptor) else {
            isSaved = false
            return
        }

        isSaved = !existing.isEmpty
    }
}

private struct FlowTagList: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags.prefix(12), id: \.self) { tag in
                    Text(tag.capitalized)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.appSurface.opacity(0.95)))
                }
            }
            .padding(.vertical, 2)
        }
    }
}

#Preview {
    ProductDetailView(product: Product.mockDeck[0])
        .modelContainer(SwiftDataContainer.preview)
}
