import SwiftUI

struct LoadingView: View {
    var title: String = "Loading..."
    var subtitle: String? = "Curating your personalized picks"

    @State private var shouldPulse = false
    @State private var shouldSpin = false
    @State private var didStartAnimations = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.16))
                    .frame(width: 112, height: 112)
                    .blur(radius: 2)
                    .offset(x: shouldPulse ? -18 : 18, y: shouldPulse ? -14 : 14)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: shouldPulse)

                Circle()
                    .fill(Color.appAccent.opacity(0.1))
                    .frame(width: 128, height: 128)
                    .offset(x: shouldPulse ? 18 : -18, y: shouldPulse ? 12 : -12)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: shouldPulse)

                Circle()
                    .stroke(Color.appBorder.opacity(0.3), lineWidth: 9)
                    .frame(width: 84, height: 84)

                Circle()
                    .trim(from: 0.1, to: 0.78)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.3),
                                Color.appAccent,
                                Color.appAccent.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .frame(width: 84, height: 84)
                    .rotationEffect(.degrees(shouldSpin ? 360 : 0))
                    .animation(.linear(duration: 1.05).repeatForever(autoreverses: false), value: shouldSpin)

                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.appAccent)
                    .scaleEffect(shouldPulse ? 1.08 : 0.92)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: shouldPulse)
            }
            .frame(width: 150, height: 150)

            Text(title)
                .font(AppTypography.navigationLabel.weight(.semibold))
                .multilineTextAlignment(.center)

            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            LoadingDots()
                .padding(.top, 2)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.appBorder.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, y: 10)
        .onAppear {
            guard !didStartAnimations else { return }
            didStartAnimations = true
            shouldPulse = true
            shouldSpin = true
        }
    }
}

private struct LoadingDots: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 8) {
            dot(delay: 0)
            dot(delay: 0.14)
            dot(delay: 0.28)
        }
        .onAppear {
            isAnimating = true
        }
    }

    private func dot(delay: Double) -> some View {
        Circle()
            .fill(Color.appAccent.opacity(0.85))
            .frame(width: 7, height: 7)
            .scaleEffect(isAnimating ? 1 : 0.65)
            .opacity(isAnimating ? 0.95 : 0.35)
            .animation(
                .easeInOut(duration: 0.72)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.appBackground, Color.appSurface.opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        LoadingView(title: "Loading your feed")
            .padding(24)
    }
}

#Preview("Compact") {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()

        LoadingView(title: "Fetching fresh products", subtitle: "Hang tight")
            .padding(24)
    }
}
