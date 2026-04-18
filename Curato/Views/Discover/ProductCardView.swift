import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImageView(urlString: product.imageURL, height: 260)

            VStack(alignment: .leading, spacing: 8) {
                Text(product.merchant)
                    .font(AppTypography.productBrand)
                    .foregroundStyle(.secondary)

                Text(product.title)
                    .font(AppTypography.productTitle)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(PriceFormatter.string(from: product.price))
                        .font(AppTypography.productPrice)

                    if let original = product.originalPrice {
                        Text(PriceFormatter.string(from: original))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .strikethrough()
                    }
                }

                if let reason = product.reasonText {
                    Text(reason)
                        .font(AppTypography.recommendationReason)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .appCardStyle()
    }
}
