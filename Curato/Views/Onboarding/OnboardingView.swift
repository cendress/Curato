import SwiftData
import SwiftUI

struct OnboardingView: View {
    let session: AppSessionState
    let profile: UserPreferenceProfile?

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: OnboardingViewModel
    @State private var isMovingForward = true

    init(session: AppSessionState, profile: UserPreferenceProfile?) {
        self.session = session
        self.profile = profile
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(session: session))
    }

    var body: some View {
        ZStack {
            OnboardingBackgroundView(step: viewModel.currentStep)

            VStack(spacing: 0) {
                OnboardingProgressHeaderView(
                    currentStep: viewModel.currentStep,
                    progress: viewModel.progress,
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                            viewModel.previousStep()
                        }
                        Haptic.light()
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 6)

                stepView
                    .id(viewModel.currentStep)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .transition(stepTransition)

                Spacer(minLength: 8)

                PrimaryButton(
                    title: viewModel.currentStep.ctaTitle,
                    isEnabled: viewModel.canContinue && !viewModel.isSaving
                ) {
                    handlePrimaryAction()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.52, dampingFraction: 0.9), value: viewModel.currentStep)
    }

    @ViewBuilder
    private var stepView: some View {
        switch viewModel.currentStep {
        case .welcome:
            WelcomeOnboardingStepView()
        case .vibeIntent:
            VibeIntentOnboardingStepView(viewModel: viewModel)
        case .preferences:
            PreferencesOnboardingStepView(viewModel: viewModel)
        }
    }

    private var stepTransition: AnyTransition {
        if isMovingForward {
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        } else {
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }

    private func handlePrimaryAction() {
        guard viewModel.canContinue else {
            Haptic.selection()
            return
        }

        if viewModel.currentStep == .preferences {
            withAnimation(.snappy(duration: 0.55, extraBounce: 0.02)) {
                _ = viewModel.completeOnboarding(session: session, profile: profile, modelContext: modelContext)
            }
            return
        }

        isMovingForward = true
        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            viewModel.nextStep()
        }
        Haptic.light()
    }
}

#Preview {
    OnboardingView(session: AppSessionState(), profile: UserPreferenceProfile())
        .modelContainer(SwiftDataContainer.preview)
}
