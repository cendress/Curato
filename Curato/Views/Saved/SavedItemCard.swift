import SwiftUI

struct SavedItemCard: View {
    let product: SavedProduct
    let savedDateText: String

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(urlString: product.imageURL, height: 88)
                .frame(width: 88)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.merchant)
                    .font(AppTypography.productBrand)
                    .foregroundStyle(.secondary)

                Text(product.title)
                    .font(AppTypography.productTitle)
                    .lineLimit(2)

                Text(PriceFormatter.string(from: product.price))
                    .font(AppTypography.productPrice)

                Text("Saved \(savedDateText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .appCardStyle()
    }
}
