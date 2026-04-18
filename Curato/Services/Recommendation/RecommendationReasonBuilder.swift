import Foundation

struct RecommendationExplanation {
    let matchedVibeTags: [String]
    let matchedPreferenceTags: [String]
    let matchedCategory: String?
    let isWithinBudget: Bool
    let hasStrongRating: Bool
}

protocol RecommendationReasonBuilding {
    func buildReason(explanation: RecommendationExplanation) -> String
}

struct RecommendationReasonBuilder: RecommendationReasonBuilding {
    func buildReason(explanation: RecommendationExplanation) -> String {
        if let vibe = explanation.matchedVibeTags.first, explanation.isWithinBudget {
            return "Recommended because it matches your \(readable(vibe)) style and budget."
        }

        if let preferenceTag = explanation.matchedPreferenceTags.first {
            return "Recommended because you've been saving similar \(readable(preferenceTag))."
        }

        if !explanation.matchedVibeTags.isEmpty, explanation.hasStrongRating {
            return "Recommended because it fits your vibe and is highly rated."
        }

        if let category = explanation.matchedCategory, explanation.isWithinBudget {
            return "Recommended because it matches your \(readable(category)) picks and budget."
        }

        return "Recommended because it matches your current shopping vibe."
    }

    private func readable(_ token: String) -> String {
        token
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
    }
}
