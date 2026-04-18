import SwiftUI

struct EmptySavedStateView: View {
    var body: some View {
        EmptyStateView(
            iconName: "bookmark",
            title: "No saved products yet",
            subtitle: "When you like something in Discover, save it from the detail sheet and it will appear here."
        )
    }
}
