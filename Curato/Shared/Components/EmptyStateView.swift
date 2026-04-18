import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(Color.appAccent)

            Text(title)
                .font(AppTypography.sectionHeaderSmall)

            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 240)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}
