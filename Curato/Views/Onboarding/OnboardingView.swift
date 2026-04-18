import SwiftData
import SwiftUI

struct OnboardingView: View {
    let session: AppSessionState
    let profile: UserPreferenceProfile?

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Find products that match your vibe")
                        .font(AppTypography.welcomeHeadline)

                    sectionTitle("Pick a style vibe")
                    FlowLayout(data: viewModel.vibeSuggestions, spacing: 8) { vibe in
                        VibeChip(title: vibe, isSelected: viewModel.selectedVibe == vibe) {
                            viewModel.selectedVibe = vibe
                            Haptic.selection()
                        }
                    }

                    sectionTitle("Choose a budget")
                    FlowLayout(data: viewModel.budgetPresets, spacing: 8) { preset in
                        BudgetChip(title: preset.label, isSelected: viewModel.selectedBudgetID == preset.id) {
                            viewModel.selectedBudgetID = preset.id
                            Haptic.selection()
                        }
                    }

                    sectionTitle("Favorite categories")
                    FlowLayout(data: viewModel.categorySuggestions, spacing: 8) { category in
                        VibeChip(title: category, isSelected: viewModel.selectedCategories.contains(category)) {
                            if viewModel.selectedCategories.contains(category) {
                                viewModel.selectedCategories.remove(category)
                            } else {
                                viewModel.selectedCategories.insert(category)
                            }
                        }
                    }

                    sectionTitle("Location (optional)")
                    TextField("e.g. New York, NY", text: $viewModel.location)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Start Discovering", isEnabled: !viewModel.selectedVibe.isEmpty) {
                    viewModel.completeOnboarding(session: session, profile: profile, modelContext: modelContext)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.appBackground)
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.sectionHeaderSmall)
    }
}

#Preview {
    OnboardingView(session: AppSessionState(), profile: UserPreferenceProfile())
        .modelContainer(SwiftDataContainer.preview)
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: spacing)], alignment: .leading, spacing: spacing) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
            }
        }
    }
}
