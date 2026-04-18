import SwiftData
import SwiftUI

@main
struct CuratoApp: App {
    private let modelContainer = SwiftDataContainer.shared

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
