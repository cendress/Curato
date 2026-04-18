import SwiftUI

struct BudgetChip: View {
    let title: String
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.86))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.appAccent : Color.white.opacity(0.7))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder((isSelected ? Color.appAccent : Color.appBorder).opacity(isSelected ? 0 : 0.4), lineWidth: 1)
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        BudgetChip(title: "Under $100", isSelected: false, onTap: {})
        BudgetChip(title: "No limit", isSelected: true, onTap: {})
    }
    .padding()
    .background(Color.appBackground)
}
