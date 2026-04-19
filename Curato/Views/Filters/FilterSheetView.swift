import SwiftUI

struct FilterSheetView: View {
    let onApply: (FilterOptions) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FilterSheetViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case vibe
    }

    init(initialOptions: FilterOptions, onApply: @escaping (FilterOptions) -> Void) {
        self.onApply = onApply
        _viewModel = StateObject(wrappedValue: FilterSheetViewModel(initialOptions: initialOptions))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appSurface.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Refine your feed")
                                .font(AppTypography.sectionHeaderLarge)
                            Text("Edit your vibe and preferences to refresh your product stream.")
                                .font(AppTypography.recommendationReason)
                                .foregroundStyle(.secondary)
                        }

                        sectionCard(title: "Vibe") {
                            TextField("Minimal spring outfits", text: $viewModel.workingOptions.vibeText)
                                .focused($focusedField, equals: .vibe)
                                .textInputAutocapitalization(.sentences)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                                )

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                                ForEach(viewModel.vibeSuggestions, id: \.self) { vibe in
                                    VibeChip(
                                        title: vibe,
                                        isSelected: viewModel.workingOptions.vibeText.localizedCaseInsensitiveContains(vibe)
                                    ) {
                                        viewModel.applyVibeSuggestion(vibe)
                                        Haptic.selection()
                                    }
                                }
                            }
                        }

                        sectionCard(title: "Budget") {
                            Text(viewModel.selectedBudgetPreset.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appAccent)

                            Slider(
                                value: $viewModel.selectedBudgetSliderValue,
                                in: 0 ... 3,
                                step: 1
                            )
                            .tint(Color.appAccent)

                            HStack(spacing: 8) {
                                ForEach(viewModel.budgetPresets) { preset in
                                    BudgetChip(
                                        title: preset.label,
                                        isSelected: preset.id == viewModel.selectedBudgetPreset.id
                                    ) {
                                        viewModel.selectedBudgetSliderValue = preset.sliderValue
                                    }
                                }
                            }
                        }

                        sectionCard(title: "Categories") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.categorySuggestions, id: \.self) { category in
                                        VibeChip(
                                            title: category,
                                            isSelected: viewModel.workingOptions.selectedCategories.contains(category)
                                        ) {
                                            viewModel.toggleCategory(category)
                                        }
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }

                        sectionCard(title: "Style framing") {
                            Picker("Style framing", selection: $viewModel.selectedStyleFrame) {
                                ForEach(FilterSheetViewModel.StyleFrame.allCases) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 120)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(AppTypography.navigationLabel)
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 10) {
                    Button("Reset") {
                        viewModel.clear()
                        Haptic.selection()
                    }
                    .font(AppTypography.buttonText)
                    .foregroundStyle(Color.appAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.appBorder.opacity(0.35), lineWidth: 1)
                    )

                    PrimaryButton(title: "Apply") {
                        focusedField = nil
                        Haptic.light()
                        onApply(viewModel.appliedOptions)
                        dismiss()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(.ultraThinMaterial)
            }
        }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTypography.sectionHeaderSmall)
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    FilterSheetView(
        initialOptions: FilterOptions(vibeText: "Minimal", budgetMin: nil, budgetMax: 150, selectedCategories: ["Tops"])
    ) { _ in }
}
