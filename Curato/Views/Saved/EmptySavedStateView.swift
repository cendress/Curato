import SwiftUI

struct EmptySavedStateView: View {
    var body: some View {
        EmptyStateView(
            iconName: "bookmark",
            title: "Nothing saved yet",
            subtitle: "Swipe right or tap save on items you want to keep."
        )
    }
}
