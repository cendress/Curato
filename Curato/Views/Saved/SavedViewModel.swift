import Combine
import Foundation
import SwiftData

@MainActor
final class SavedViewModel: ObservableObject {
    func delete(_ product: SavedProduct, from modelContext: ModelContext) {
        modelContext.delete(product)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to delete saved product: \(error.localizedDescription)")
        }
    }

    func dateLabel(for date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
