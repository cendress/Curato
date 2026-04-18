import SwiftUI

struct LoadingView: View {
    var title: String = "Loading..."

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(title)
                .font(AppTypography.navigationLabel)
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }
}

#Preview {
    LoadingView(title: "Loading...")
}
