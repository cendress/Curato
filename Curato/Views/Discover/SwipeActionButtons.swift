import SwiftUI

struct SwipeActionButtons: View {
    var onPass: () -> Void
    var onSave: () -> Void
    var onLike: () -> Void

    var body: some View {
        HStack(spacing: 22) {
            actionButton(
                systemName: "xmark",
                tint: .red,
                size: 58,
                action: onPass
            )
            actionButton(
                systemName: "bookmark.fill",
                tint: .blue,
                size: 54,
                action: onSave
            )
            actionButton(
                systemName: "heart.fill",
                tint: .green,
                size: 58,
                action: onLike
            )
        }
    }

    private func actionButton(
        systemName: String,
        tint: Color,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle()
                        .stroke(tint.opacity(0.28), lineWidth: 1.4)
                )
                .shadow(color: .black.opacity(0.16), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityLabel(accessibilityLabel(for: systemName))
    }

    private func accessibilityLabel(for systemName: String) -> String {
        switch systemName {
        case "xmark":
            return "Pass"
        case "bookmark.fill":
            return "Save"
        default:
            return "Like"
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.black.opacity(0.4), .clear],
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(height: 160)

        VStack {
            Spacer()
            SwipeActionButtons(onPass: {}, onSave: {}, onLike: {})
                .padding(.bottom, 14)
        }
        .frame(height: 160)
    }
    .padding()
    .background(Color.appBackground)
}
