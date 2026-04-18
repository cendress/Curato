import SwiftUI

struct BudgetChip: View {
    let title: String
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(AppTypography.filterChip)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.appAccent : Color.appSurface)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.appBorder.opacity(0.5), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
