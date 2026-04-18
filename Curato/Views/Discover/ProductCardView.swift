import SwiftUI

struct ProductCardView: View {
    let product: Product
    var isOpaque: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsyncImageView(urlString: product.imageURL, height: 360)

            VStack(alignment: .leading, spacing: 10) {
                Text(product.merchant)
                    .font(AppTypography.productBrand)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(product.title)
                    .font(AppTypography.productTitle)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(PriceFormatter.string(from: product.price))
                        .font(AppTypography.productPrice)

                    if let original = product.originalPrice {
                        Text(PriceFormatter.string(from: original))
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
                        .foregroundStyle(.secondary.opacity(0.9))
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(isOpaque ? 1 : 0.84))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.appBorder.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 12)
    }
}

#Preview {
    ProductCardView(product: Product.mockDeck[0])
        .padding()
        .background(Color.appBackground)
}
