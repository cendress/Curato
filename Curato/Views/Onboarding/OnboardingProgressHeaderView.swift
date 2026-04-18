import SwiftUI

struct OnboardingProgressHeaderView: View {
    let currentStep: OnboardingViewModel.Step
    let progress: Double
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if currentStep == .welcome {
                Color.clear
                    .frame(width: 36, height: 36)
            } else {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Step \(currentStep.rawValue + 1) of \(OnboardingViewModel.Step.allCases.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.22))

                        Capsule()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

#Preview {
    OnboardingProgressHeaderView(currentStep: .vibeIntent, progress: 0.66, onBack: {})
        .padding()
        .background(Color.gray)
}
