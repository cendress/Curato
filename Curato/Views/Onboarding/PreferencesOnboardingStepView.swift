import SwiftUI

struct PreferencesOnboardingStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isLocationFieldFocused: Bool

    private let categoryColumns = [GridItem(.adaptive(minimum: 120), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Set a few preferences")
                    .font(AppTypography.sectionHeaderLarge)
                    .foregroundStyle(.white)

                Text("These help us tailor your feed.")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.84))
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Budget")
                        .font(AppTypography.navigationLabel)
                        .foregroundStyle(.white)

                    Spacer()

                    Text(viewModel.selectedBudgetPreset.label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.95))
                }

                Slider(value: $viewModel.selectedBudgetSliderValue, in: 0 ... 3, step: 1)
                    .tint(.white)
                    .onChange(of: viewModel.selectedBudgetSliderValue) { _, _ in
                        Haptic.selection()
                    }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(viewModel.budgetPresets) { preset in
                        BudgetChip(
                            title: preset.label,
                            isSelected: viewModel.selectedBudgetPreset.id == preset.id
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                                viewModel.selectBudgetPreset(preset)
                            }
                            Haptic.selection()
                        }
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("Style framing")
                    .font(AppTypography.navigationLabel)
                    .foregroundStyle(.white)

                Picker("Style framing", selection: $viewModel.selectedStyleFrame) {
                    ForEach(OnboardingViewModel.StyleFrame.allCases) { frame in
                        Text(frame.rawValue).tag(frame)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Categories")
                    .font(AppTypography.navigationLabel)
                    .foregroundStyle(.white)

                LazyVGrid(columns: categoryColumns, alignment: .leading, spacing: 10) {
                    ForEach(viewModel.categorySuggestions, id: \.self) { category in
                        VibeChip(title: category, isSelected: viewModel.selectedCategories.contains(category)) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                viewModel.toggleCategory(category)
                            }
                            Haptic.selection()
                        }
                    }
                }
            }

//            VStack(alignment: .leading, spacing: 10) {
//                Text("Location (optional)")
//                    .font(AppTypography.navigationLabel)
//                    .foregroundStyle(.white)
//
//                TextField("e.g. NYC", text: $viewModel.location)
//                    .focused($isLocationFieldFocused)
//                    .textInputAutocapitalization(.words)
//                    .submitLabel(.done)
//                    .padding(12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 14, style: .continuous)
//                            .fill(Color.white.opacity(0.92))
//                    )
//            }

            Spacer()
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isLocationFieldFocused = false
                }
                .font(.headline)
            }
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackgroundView(step: .preferences)
        PreferencesOnboardingStepView(viewModel: OnboardingViewModel())
            .padding(.horizontal, 20)
    }
}
