import SwiftUI

struct VibeIntentOnboardingStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isIntentFieldFocused: Bool
    
    private let gridColumns = [GridItem(.adaptive(minimum: 120), spacing: 10)]
    private let maxIntentCharacters = 60
    
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                Text("What are you shopping for?")
                    .font(AppTypography.sectionHeaderLarge)
                    .foregroundStyle(.white)
                
                Text("Tap vibe chips, type a custom intent, or combine both for better recommendations.")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.84))
            }
            
            LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 10) {
                ForEach(viewModel.vibeSuggestions, id: \.self) { vibe in
                    VibeChip(title: vibe, isSelected: viewModel.selectedVibes.contains(vibe)) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            viewModel.toggleVibe(vibe)
                        }
                        Haptic.selection()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Or describe your intent")
                    .font(AppTypography.navigationLabel)
                    .foregroundStyle(.white)
                
                TextField(
                    "Minimal spring outfits for NYC under $150",
                    text: $viewModel.customIntentText,
                    axis: .vertical
                )
                .focused($isIntentFieldFocused)
                .lineLimit(2...5)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .font(.body)
                .foregroundStyle(Color.black.opacity(0.8))
                .onChange(of: viewModel.customIntentText) { _, newValue in
                    if newValue.count > maxIntentCharacters {
                        viewModel.customIntentText = String(newValue.prefix(maxIntentCharacters))
                    }
                }
                
                HStack {
                    Spacer()
                    Text("\(viewModel.customIntentText.count)/\(maxIntentCharacters)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
            
            Spacer()
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isIntentFieldFocused = false
                }
                .font(.headline)
            }
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackgroundView(step: .vibeIntent)
        VibeIntentOnboardingStepView(viewModel: OnboardingViewModel())
            .padding(.horizontal, 20)
    }
}
