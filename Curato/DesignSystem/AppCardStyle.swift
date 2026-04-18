import SwiftUI

struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appBorder.opacity(0.5), lineWidth: 1)
            )
    }
}

extension View {
    func appCardStyle() -> some View {
        modifier(AppCardStyle())
    }
}
