import SwiftUI

struct SavedItemCard: View {
    let product: SavedProduct
    let savedDateText: String

    var body: some View {
        HStack(spacing: 14) {
            AsyncImageView(urlString: product.imageURL, height: 104)
                .frame(width: 92)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(product.merchant)
                    .font(AppTypography.productBrand)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(product.title)
                    .font(AppTypography.productTitle.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    Text(PriceFormatter.string(from: product.price))
                        .font(AppTypography.productPrice)

                    if let originalPrice = product.originalPrice, let price = product.price, originalPrice > price {
                        Text(originalPrice.asCurrency)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .strikethrough()
                    }
                }

                Text("Saved \(savedDateText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.07), radius: 12, y: 8)
    }
}

#Preview {
    SavedItemCard(
        product: SavedProduct.from(product: Product.mockDeck[0]),
        savedDateText: "Apr 18, 2026"
    )
    .padding()
    .background(Color.appBackground)
}
