import SwiftData
import SwiftUI

struct MainTabView: View {
    let session: AppSessionState

    var body: some View {
        TabView {
            DiscoverView(session: session)
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }

            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
        }
        .tint(.appAccent)
    }
}

#Preview {
    MainTabView(session: AppSessionState(hasCompletedOnboarding: true))
        .modelContainer(SwiftDataContainer.preview)
}
