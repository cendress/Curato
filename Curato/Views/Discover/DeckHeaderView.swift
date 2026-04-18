import SwiftUI

struct DeckHeaderView: View {
    let vibeText: String
    var onTapFilter: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Discover")
                    .font(AppTypography.sectionHeaderLarge)

                Text(vibeText.isEmpty ? "Swipe to tune your taste" : "Vibe: \(vibeText)")
                    .font(AppTypography.recommendationReason)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onTapFilter) {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline)
                    .padding(10)
                    .background(Circle().fill(Color.appSurface))
            }
            .buttonStyle(.plain)
        }
    }
}
