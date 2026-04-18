import SwiftUI

struct SwipeActionButtons: View {
    var onSkip: () -> Void
    var onLike: () -> Void
    var onInfo: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            iconButton(systemName: "xmark", tint: .red, action: onSkip)
            iconButton(systemName: "info.circle", tint: .blue, action: onInfo)
            iconButton(systemName: "heart.fill", tint: .green, action: onLike)
        }
        .padding(.vertical, 8)
    }

    private func iconButton(systemName: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 54, height: 54)
                .background(Circle().fill(Color.appSurface))
        }
        .buttonStyle(.plain)
    }
}
