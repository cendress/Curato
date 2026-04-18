import SwiftUI

struct VibeChip: View {
    let title: String
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(AppTypography.filterChip.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Capsule(style: .continuous)
                        .fill(chipBackground)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(isSelected ? Color.white.opacity(0.28) : Color.appBorder.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: .black.opacity(isSelected ? 0.14 : 0.06), radius: isSelected ? 10 : 4, y: isSelected ? 6 : 2)
                .scaleEffect(isSelected ? 1.03 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    private var chipBackground: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [Color.appAccent, Color.appAccent.opacity(0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [Color.white.opacity(0.9), Color.appSurface.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        VibeChip(title: "Minimal", isSelected: false, onTap: {})
        VibeChip(title: "Streetwear", isSelected: true, onTap: {})
    }
    .padding()
    .background(Color.appBackground)
}
