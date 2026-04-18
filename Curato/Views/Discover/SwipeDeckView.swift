import SwiftUI

struct SwipeDeckView: View {
    enum DeckDecision {
        case pass
        case save
        case like
    }

    private enum DecisionTriggerSource {
        case gesture
        case actionButton
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
    @State private var animatingProductID: String?
    @State private var isAwaitingDeckSwap = false
    @State private var displayedNextProduct: Product?
    @State private var actionControlsRevealProgress: Double = 0

    private let swipeThreshold: CGFloat = 110
    private let actionAreaHeight: CGFloat = 112
    private let deckTopInset: CGFloat = 12
    private let deckBottomInset: CGFloat = 20
    private let actionControlsTransitionAnimation = Animation.easeOut(duration: 0.15)

    private struct OverlayStyle {
        let color: Color
        let iconName: String
        let badgeAlignment: Alignment
    }

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = max(0, geometry.size.height - deckTopInset - deckBottomInset)

            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    if let displayedNextProduct {
                        ProductCardView(
                            product: displayedNextProduct,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            bottomContentInset: actionAreaHeight
                        )
                        .overlay {
                            backCardBottomGradient
                        }
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .allowsHitTesting(false)
                    }

                    ProductCardView(
                        product: product,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        isOpaque: true,
                        bottomContentInset: actionAreaHeight
                    )
                    .overlay {
                        cardOverlayChrome
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .offset(x: effectiveDragOffset.width, y: effectiveDragOffset.height)
                    .rotationEffect(.degrees(Double(effectiveDragOffset.width / 24)), anchor: .bottom)
                    .onTapGesture {
                        guard !isCurrentCardAnimatingOut else { return }
                        onOpenDetail()
                    }
                    .zIndex(1)
                }
                .frame(width: cardWidth, height: cardHeight, alignment: .topLeading)
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            guard !isCurrentCardAnimatingOut else { return }
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            guard !isCurrentCardAnimatingOut else { return }
                            let horizontalOffset = value.translation.width
                            if horizontalOffset <= -swipeThreshold {
                                triggerDecision(.pass, source: .gesture)
                            } else if horizontalOffset >= swipeThreshold {
                                triggerDecision(.like, source: .gesture)
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
                    animatingProductID = nil
                    isAwaitingDeckSwap = false
                    animateActionControlsIn(fromHidden: true)
                }
                .onChange(of: product.id) {
                    resetInteractionState(disableAnimations: true)
                    displayedNextProduct = nextProduct
                    isAwaitingDeckSwap = false
                    animateActionControlsIn(fromHidden: true)
                }
                .onChange(of: nextProduct?.id) {
                    guard !isInteracting, !isAwaitingDeckSwap else { return }
                    displayedNextProduct = nextProduct
                }
                .onChange(of: isInteracting) { interacting in
                    if !interacting {
                        if !isAwaitingDeckSwap {
                            displayedNextProduct = nextProduct
                        }
                        animateActionControlsIn()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, deckTopInset)
            .padding(.bottom, deckBottomInset)
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

    private var backCardBottomGradient: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            actionAreaGradient
                .frame(height: actionAreaHeight)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .allowsHitTesting(false)
    }

    private var actionAreaGradient: some View {
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
    }

    private var actionControlsOverlay: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            ZStack(alignment: .bottom) {
                actionAreaGradient

                SwipeActionButtons(
                    onPass: { triggerDecision(.pass, source: .actionButton) },
                    onSave: { triggerDecision(.save, source: .actionButton) },
                    onLike: { triggerDecision(.like, source: .actionButton) }
                )
                .padding(.bottom, 14)
                .padding(.horizontal, 18)
                .opacity(actionControlsOpacity)
                .offset(y: actionControlsOffsetY)
                .scaleEffect(0.98 + (CGFloat(actionControlsOpacity) * 0.02))
                .animation(actionControlsTransitionAnimation, value: actionControlsOpacity)
                .allowsHitTesting(actionControlsOpacity > 0.05 && !isCurrentCardAnimatingOut)
            }
            .frame(height: actionAreaHeight)
        }
    }

    @ViewBuilder
    private var swipeOverlay: some View {
        if let style = overlayStyle {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(style.color.opacity(overlayOpacity))

                GeometryReader { proxy in
                    Image(systemName: style.iconName)
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 92, height: 92)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.16))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.94), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: style.badgeAlignment)
                        .padding(.horizontal, 24)
                        .padding(.top, max(24, proxy.size.height * 0.14))
                }
            }
            .allowsHitTesting(false)
            .animation(.easeOut(duration: 0.12), value: overlayOpacity)
        }
    }

    private var overlayStyle: OverlayStyle? {
        if let effectiveActiveDecision {
            return style(for: effectiveActiveDecision)
        }

        if effectiveDragOffset.width <= -10 {
            return style(for: .pass)
        }

        if effectiveDragOffset.width >= 10 {
            return style(for: .like)
        }

        return nil
    }

    private var effectiveDragOffset: CGSize {
        isStaleInteractionForCurrentCard ? .zero : dragOffset
    }

    private var effectiveActiveDecision: DeckDecision? {
        isStaleInteractionForCurrentCard ? nil : activeDecision
    }

    private var isStaleInteractionForCurrentCard: Bool {
        guard let animatingProductID else { return false }
        return animatingProductID != product.id
    }

    private var isCurrentCardAnimatingOut: Bool {
        isAnimatingOut && animatingProductID == product.id
    }

    private var overlayOpacity: Double {
        if effectiveActiveDecision != nil {
            return 0.46
        }

        let progress = min(Double(abs(effectiveDragOffset.width) / swipeThreshold), 1)
        return min(pow(progress, 1.35) * 0.42, 0.42)
    }

    private var swipeInteractionProgress: CGFloat {
        min(hypot(effectiveDragOffset.width, effectiveDragOffset.height) / 28, 1)
    }

    private var actionControlsOpacity: Double {
        if effectiveActiveDecision != nil || isCurrentCardAnimatingOut {
            return 0
        }
        return (1 - Double(swipeInteractionProgress)) * actionControlsRevealProgress
    }

    private var actionControlsOffsetY: CGFloat {
        CGFloat((1 - actionControlsOpacity) * 24)
    }

    private var isInteracting: Bool {
        isCurrentCardAnimatingOut
            || effectiveActiveDecision != nil
            || abs(effectiveDragOffset.width) > 0.5
            || abs(effectiveDragOffset.height) > 0.5
    }

    private func style(for decision: DeckDecision) -> OverlayStyle {
        switch decision {
        case .pass:
            return OverlayStyle(color: .red, iconName: "xmark", badgeAlignment: .topTrailing)
        case .save:
            return OverlayStyle(color: .blue, iconName: "bookmark.fill", badgeAlignment: .top)
        case .like:
            return OverlayStyle(color: .green, iconName: "heart.fill", badgeAlignment: .topLeading)
        }
    }

    private func triggerDecision(_ decision: DeckDecision, source: DecisionTriggerSource) {
        guard !isCurrentCardAnimatingOut else { return }

        animatingProductID = product.id
        isAnimatingOut = true
        activeDecision = decision
        isAwaitingDeckSwap = true

        let destination: CGSize
        switch decision {
        case .pass:
            destination = CGSize(width: -460, height: 40)
        case .save:
            destination = CGSize(width: 360, height: -180)
        case .like:
            destination = CGSize(width: 460, height: -10)
        }

        let springResponse: Double = source == .actionButton ? 0.48 : 0.3
        let springDamping: Double = source == .actionButton ? 0.9 : 0.86
        let completionDelay: Double = source == .actionButton ? 0.32 : 0.2

        withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
            dragOffset = destination
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + completionDelay) {
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
                animatingProductID = nil
                isAwaitingDeckSwap = false
                actionControlsRevealProgress = 0
            }
            return
        }

        dragOffset = .zero
        activeDecision = nil
        isAnimatingOut = false
        animatingProductID = nil
        isAwaitingDeckSwap = false
    }

    private func animateActionControlsIn(fromHidden: Bool = false) {
        if fromHidden {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                actionControlsRevealProgress = 0
            }
        }

        withAnimation(actionControlsTransitionAnimation) {
            actionControlsRevealProgress = 1
        }
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
