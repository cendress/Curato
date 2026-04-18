import SwiftUI

struct SwipeDeckView: View {
    let product: Product
    var onLike: () -> Void
    var onSkip: () -> Void
    var onInfo: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ProductCardView(product: product)

            HStack {
                Text("Tap actions below to simulate swipe decisions")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Details", action: onInfo)
                    .font(.footnote.weight(.semibold))
            }
        }
    }
}
