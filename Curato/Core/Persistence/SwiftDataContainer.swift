import SwiftData

enum SwiftDataContainer {
    static let schema = Schema([
        AppSessionState.self,
        UserPreferenceProfile.self,
        SavedProduct.self
    ])

    static let shared: ModelContainer = makeContainer(inMemory: false)
    static let preview: ModelContainer = makeContainer(inMemory: true)

    private static func makeContainer(inMemory: Bool) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
}
