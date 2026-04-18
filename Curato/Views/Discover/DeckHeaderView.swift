import SwiftUI

struct DeckHeaderView: View {
    let vibeText: String
    var onTapFilter: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Current vibe")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(vibeText.isEmpty ? "Curated just for you" : vibeText)
                    .font(AppTypography.sectionHeaderSmall)
                    .lineLimit(2)

                Text("Based on your likes and saves")
                    .font(AppTypography.recommendationReason)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onTapFilter) {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.84))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.appBorder.opacity(0.35), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.64))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    DeckHeaderView(vibeText: "Minimal spring outfits for NYC under $150", onTapFilter: {})
        .padding()
        .background(Color.appBackground)
}
