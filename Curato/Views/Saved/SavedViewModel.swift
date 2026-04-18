import Combine
import Foundation
import SwiftData

@MainActor
final class SavedViewModel: ObservableObject {
    enum SavedSortOrder: String, CaseIterable, Identifiable {
        case newest
        case oldest

        var id: String { rawValue }

        var title: String {
            switch self {
            case .newest:
                return "Newest"
            case .oldest:
                return "Oldest"
            }
        }
    }

    @Published var sortOrder: SavedSortOrder = .newest

    func sortedProducts(_ products: [SavedProduct]) -> [SavedProduct] {
        products.sorted { lhs, rhs in
            switch sortOrder {
            case .newest:
                return lhs.savedAt > rhs.savedAt
            case .oldest:
                return lhs.savedAt < rhs.savedAt
            }
        }
    }

    func delete(_ product: SavedProduct, profile: UserPreferenceProfile?, from modelContext: ModelContext) {
        modelContext.delete(product)
        profile?.unregisterSave(productID: product.id)

        do {
            try modelContext.save()
            Haptic.selection()
        } catch {
            assertionFailure("Failed to delete saved product: \(error.localizedDescription)")
        }
    }

    func clearAll(_ products: [SavedProduct], profile: UserPreferenceProfile?, from modelContext: ModelContext) {
        guard !products.isEmpty else { return }

        for product in products {
            modelContext.delete(product)
            profile?.unregisterSave(productID: product.id)
        }

        do {
            try modelContext.save()
            Haptic.light()
        } catch {
            assertionFailure("Failed to clear saved products: \(error.localizedDescription)")
        }
    }

    func dateLabel(for date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
