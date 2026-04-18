import SwiftUI

struct AppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.buttonText)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.appAccent)
            )
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
