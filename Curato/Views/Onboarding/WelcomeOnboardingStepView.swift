import SwiftUI

struct WelcomeOnboardingStepView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.95), Color.appAccent.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 116, height: 116)
                        .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Color.appAccent)
                }
                
                Text("Curato")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.98))
                    .tracking(1.1)
            }

            VStack(spacing: 8) {
                Text("Shop by vibe")
                    .font(AppTypography.welcomeHeadline)
                    .foregroundStyle(.white)

                Text("Find pieces that match your style, mood, and budget.")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackgroundView(step: .welcome)
        WelcomeOnboardingStepView()
            .padding(.horizontal, 24)
    }
}
