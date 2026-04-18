import SwiftUI

struct FilterSheetView: View {
    let onApply: (FilterOptions) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FilterSheetViewModel

    init(initialOptions: FilterOptions, onApply: @escaping (FilterOptions) -> Void) {
        self.onApply = onApply
        _viewModel = StateObject(wrappedValue: FilterSheetViewModel(initialOptions: initialOptions))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vibe") {
                    TextField("Describe your vibe", text: $viewModel.workingOptions.vibeText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.vibeSuggestions, id: \.self) { vibe in
                                VibeChip(title: vibe, isSelected: viewModel.workingOptions.vibeText == vibe) {
                                    viewModel.workingOptions.vibeText = vibe
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Budget") {
                    HStack {
                        Text("Min")
                        Spacer()
                        TextField(
                            "$0",
                            value: $viewModel.workingOptions.budgetMin,
                            format: .number
                        )
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Max")
                        Spacer()
                        TextField(
                            "$0",
                            value: $viewModel.workingOptions.budgetMax,
                            format: .number
                        )
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                    }
                }

                Section("Categories") {
                    ForEach(viewModel.categorySuggestions, id: \.self) { category in
                        Button {
                            viewModel.toggleCategory(category)
                        } label: {
                            HStack {
                                Text(category)
                                Spacer()
                                if viewModel.workingOptions.selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section("Location") {
                    TextField("Optional location", text: Binding(
                        get: { viewModel.workingOptions.location ?? "" },
                        set: { viewModel.workingOptions.location = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
            .navigationTitle("Refine")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        viewModel.clear()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply(viewModel.workingOptions)
                        dismiss()
                    }
                    .font(AppTypography.navigationLabel)
                }
            }
        }
    }
}

#Preview {
    FilterSheetView(initialOptions: FilterOptions(), onApply: { _ in })
}
