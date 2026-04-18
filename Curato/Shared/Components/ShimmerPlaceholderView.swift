import SwiftUI

struct ShimmerPlaceholderView: View {
    var cornerRadius: CGFloat = 14
    var baseColor: Color = Color.appSurface.opacity(0.7)
    var borderColor: Color = Color.appBorder.opacity(0.28)
    var highlightColor: Color = Color.white.opacity(0.92)
    var duration: Double = 1.05

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(baseColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .overlay {
                GeometryReader { geometry in
                    TimelineView(.animation(minimumInterval: 1 / 60, paused: false)) { timeline in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        let progress = t.truncatingRemainder(dividingBy: duration) / duration
                        let startX = -geometry.size.width * 1.2
                        let travel = geometry.size.width * 2.5

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, highlightColor, .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geometry.size.width * 0.46, 80), height: geometry.size.height)
                            .offset(x: startX + (travel * progress))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .allowsHitTesting(false)
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        ShimmerPlaceholderView(cornerRadius: 20)
            .frame(height: 200)

        ShimmerPlaceholderView(cornerRadius: 12)
            .frame(height: 84)
    }
    .padding()
    .background(Color.appBackground)
}
