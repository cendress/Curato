import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessionStates: [AppSessionState]
    @Query private var preferenceProfiles: [UserPreferenceProfile]

    @State private var didSeedInitialRecords = false

    private var activeSession: AppSessionState? {
        sessionStates.first
    }

    private var activeProfile: UserPreferenceProfile? {
        preferenceProfiles.first
    }

    var body: some View {
        ZStack {
            if let activeSession {
                if activeSession.hasCompletedOnboarding {
                    MainTabView(session: activeSession)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    OnboardingView(session: activeSession, profile: activeProfile)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            } else {
                LoadingView(title: "Preparing your personalized feed...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBackground)
                    .transition(.opacity)
            }
        }
        .task {
            seedInitialStateIfNeeded()
        }
        .animation(.snappy(duration: 0.55, extraBounce: 0.03), value: activeSession?.hasCompletedOnboarding)
    }

    private func seedInitialStateIfNeeded() {
        guard !didSeedInitialRecords else { return }
        didSeedInitialRecords = true

        var didInsertRecord = false

        if sessionStates.isEmpty {
            modelContext.insert(AppSessionState())
            didInsertRecord = true
        }

        if preferenceProfiles.isEmpty {
            modelContext.insert(UserPreferenceProfile())
            didInsertRecord = true
        }

        guard didInsertRecord else { return }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save initial app records: \(error.localizedDescription)")
        }
    }
}

#Preview {
    RootView()
        .modelContainer(SwiftDataContainer.preview)
}
