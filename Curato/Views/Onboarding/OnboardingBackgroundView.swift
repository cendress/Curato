import SwiftUI

struct OnboardingBackgroundView: View {
    let step: OnboardingViewModel.Step
    @State private var animateOrbs = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: animateOrbs ? .topLeading : .bottomLeading,
                endPoint: animateOrbs ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: animateOrbs)

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 24)
                .offset(x: animateOrbs ? 140 : -120, y: animateOrbs ? -250 : -110)
                .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true), value: animateOrbs)

            Circle()
                .fill(Color.appAccent.opacity(0.28))
                .frame(width: 300, height: 300)
                .blur(radius: 32)
                .offset(x: animateOrbs ? -170 : 160, y: animateOrbs ? 290 : 220)
                .animation(.easeInOut(duration: 13).repeatForever(autoreverses: true), value: animateOrbs)
        }
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .ignoresSafeArea()
        )
        .onAppear {
            animateOrbs = true
        }
    }

    private var gradientColors: [Color] {
        switch step {
        case .welcome:
            return [Color.appBackground, Color.appSurface.opacity(0.95), Color.appAccent.opacity(0.65)]
        case .vibeIntent:
            return [Color.appAccent.opacity(0.85), Color.appBackground, Color.appSurface]
        case .preferences:
            return [Color.appBackground, Color.appAccent.opacity(0.9), Color.appSurface.opacity(0.9)]
        }
    }
}

#Preview {
    OnboardingBackgroundView(step: .welcome)
}
