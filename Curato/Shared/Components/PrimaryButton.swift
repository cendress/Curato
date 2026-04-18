import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AppButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.55)
    }
}
