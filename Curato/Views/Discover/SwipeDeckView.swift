import SwiftUI

struct SwipeDeckView: View {
    enum DeckDecision {
        case pass
        case save
        case like
    }

    let product: Product
    let nextProduct: Product?
    var onPass: () -> Void
    var onSave: () -> Void
    var onLike: () -> Void
    var onOpenDetail: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var activeDecision: DeckDecision?
    @State private var isAnimatingOut = false
    @State private var displayedNextProduct: Product?

    private let swipeThreshold: CGFloat = 110
    private let actionAreaHeight: CGFloat = 112

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                if let displayedNextProduct {
                    ProductCardView(
                        product: displayedNextProduct,
                        bottomContentInset: actionAreaHeight
                    )
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .allowsHitTesting(false)
                }

                ProductCardView(
                    product: product,
                    isOpaque: true,
                    bottomContentInset: actionAreaHeight
                )
                    .overlay {
                        cardOverlayChrome
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .offset(x: dragOffset.width, y: dragOffset.height)
                    .rotationEffect(.degrees(Double(dragOffset.width / 24)), anchor: .bottom)
                    .onTapGesture {
                        guard !isAnimatingOut else { return }
                        onOpenDetail()
                    }
                    .zIndex(1)
            }
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        guard !isAnimatingOut else { return }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        guard !isAnimatingOut else { return }
                        let horizontalOffset = value.translation.width
                        if horizontalOffset <= -swipeThreshold {
                            triggerDecision(.pass)
                        } else if horizontalOffset >= swipeThreshold {
                            triggerDecision(.like)
                        } else {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                                dragOffset = .zero
                                activeDecision = nil
                            }
                        }
                    }
            )
            .onAppear {
                displayedNextProduct = nextProduct
            }
            .onChange(of: product.id) {
                resetInteractionState(disableAnimations: true)
                displayedNextProduct = nextProduct
            }
            .onChange(of: nextProduct?.id) {
                guard !isInteracting else { return }
                displayedNextProduct = nextProduct
            }
            .onChange(of: isInteracting) { interacting in
                if !interacting {
                    displayedNextProduct = nextProduct
                }
            }
        }
    }

    @ViewBuilder
    private var cardOverlayChrome: some View {
        ZStack {
            swipeOverlay
            actionControlsOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var actionControlsOverlay: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.5),
                        Color.black.opacity(0.24),
                        Color.black.opacity(0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .allowsHitTesting(false)

                SwipeActionButtons(
                    onPass: { triggerDecision(.pass) },
                    onSave: { triggerDecision(.save) },
                    onLike: { triggerDecision(.like) }
                )
                .padding(.bottom, 14)
                .padding(.horizontal, 18)
                .opacity(actionControlsOpacity)
                .offset(y: actionControlsOffsetY)
                .scaleEffect(0.98 + (CGFloat(actionControlsOpacity) * 0.02))
                .animation(.easeOut(duration: 0.15), value: actionControlsOpacity)
                .allowsHitTesting(actionControlsOpacity > 0.05 && !isAnimatingOut)
            }
            .frame(height: actionAreaHeight)
        }
    }

    @ViewBuilder
    private var swipeOverlay: some View {
        if let style = overlayStyle {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(style.color.opacity(overlayOpacity))

                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: style.iconName)
                        .font(.title3.weight(.black))
                    Text(style.label)
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.22))
                )
                .padding(18)
            }
            .allowsHitTesting(false)
            .animation(.easeOut(duration: 0.12), value: overlayOpacity)
        }
    }

    private var overlayStyle: (color: Color, iconName: String, label: String)? {
        if let activeDecision {
            return style(for: activeDecision)
        }

        if dragOffset.width <= -10 {
            return style(for: .pass)
        }

        if dragOffset.width >= 10 {
            return style(for: .like)
        }

        return nil
    }

    private var overlayOpacity: Double {
        if activeDecision != nil {
            return 0.4
        }
        return min(Double(abs(dragOffset.width) / swipeThreshold), 0.42)
    }

    private var swipeInteractionProgress: CGFloat {
        min(hypot(dragOffset.width, dragOffset.height) / 28, 1)
    }

    private var actionControlsOpacity: Double {
        if activeDecision != nil || isAnimatingOut {
            return 0
        }
        return 1 - Double(swipeInteractionProgress)
    }

    private var actionControlsOffsetY: CGFloat {
        CGFloat((1 - actionControlsOpacity) * 24)
    }

    private var isInteracting: Bool {
        isAnimatingOut
            || activeDecision != nil
            || abs(dragOffset.width) > 0.5
            || abs(dragOffset.height) > 0.5
    }

    private func style(for decision: DeckDecision) -> (color: Color, iconName: String, label: String) {
        switch decision {
        case .pass:
            return (.red, "xmark", "PASS")
        case .save:
            return (.blue, "bookmark.fill", "SAVED")
        case .like:
            return (.green, "heart.fill", "LIKE")
        }
    }

    private func triggerDecision(_ decision: DeckDecision) {
        guard !isAnimatingOut else { return }

        isAnimatingOut = true
        activeDecision = decision

        let destination: CGSize
        switch decision {
        case .pass:
            destination = CGSize(width: -460, height: 40)
        case .save:
            destination = CGSize(width: 360, height: -180)
        case .like:
            destination = CGSize(width: 460, height: -10)
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            dragOffset = destination
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch decision {
            case .pass:
                onPass()
            case .save:
                onSave()
            case .like:
                onLike()
            }

            // If parent state did not replace the card, restore interaction state.
            resetInteractionState(disableAnimations: true)
        }
    }

    private func resetInteractionState(disableAnimations: Bool) {
        if disableAnimations {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                dragOffset = .zero
                activeDecision = nil
                isAnimatingOut = false
            }
            return
        }

        dragOffset = .zero
        activeDecision = nil
        isAnimatingOut = false
    }
}

#Preview {
    SwipeDeckView(
        product: Product.mockDeck[0],
        nextProduct: Product.mockDeck[1],
        onPass: {},
        onSave: {},
        onLike: {},
        onOpenDetail: {}
    )
    .padding()
    .background(Color.appBackground)
}
