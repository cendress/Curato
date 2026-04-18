import SwiftUI

struct SwipeActionButtons: View {
    var onPass: () -> Void
    var onSave: () -> Void
    var onLike: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            actionButton(
                title: "Pass",
                systemName: "xmark",
                gradient: [Color.red.opacity(0.9), Color.red.opacity(0.7)],
                action: onPass
            )
            actionButton(
                title: "Save",
                systemName: "bookmark.fill",
                gradient: [Color.blue.opacity(0.92), Color.cyan.opacity(0.82)],
                action: onSave
            )
            actionButton(
                title: "Like",
                systemName: "heart.fill",
                gradient: [Color.green.opacity(0.9), Color.mint.opacity(0.8)],
                action: onLike
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.75))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.appBorder.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.07), radius: 10, y: 8)
    }

    private func actionButton(
        title: String,
        systemName: String,
        gradient: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .font(.headline.weight(.bold))
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 82, height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SwipeActionButtons(onPass: {}, onSave: {}, onLike: {})
        .padding()
        .background(Color.appBackground)
}
