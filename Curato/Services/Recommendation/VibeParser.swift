import Foundation

protocol VibeParsing {
    func parseVibeText(_ input: String) -> [String]
}

struct VibeParser: VibeParsing {
    func parseVibeText(_ input: String) -> [String] {
        let normalized = input.lowercased()
        let tokens = normalized
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }

        var tags: [String] = []

        appendUnique("shopping", to: &tags)

        for token in tokens {
            appendUnique(token, to: &tags)

            if styleKeywords.contains(token) {
                appendUnique(token, to: &tags)
            }

            if let categoryTag = categoryKeywordMap[token] {
                appendUnique(categoryTag, to: &tags)
            }

            if seasonKeywords.contains(token) {
                appendUnique(token, to: &tags)
            }
        }

        if normalized.contains("outfit") || normalized.contains("fits") {
            appendUnique("outfit", to: &tags)
        }

        if normalized.contains("basic") || normalized.contains("basics") {
            appendUnique("basics", to: &tags)
        }

        if let budget = extractBudgetMax(from: normalized) {
            appendUnique("budget-conscious", to: &tags)
            appendUnique("budget-under-\(Int(budget))", to: &tags)
        }

        return tags
    }

    private let styleKeywords: Set<String> = [
        "minimal", "streetwear", "vintage", "office", "summer", "date", "night", "casual",
        "formal", "clean", "soft", "masculine", "feminine", "luxury", "sporty", "classic"
    ]

    private let seasonKeywords: Set<String> = ["spring", "summer", "fall", "winter"]

    private let categoryKeywordMap: [String: String] = [
        "top": "tops",
        "tops": "tops",
        "shirt": "tops",
        "pants": "pants",
        "trousers": "pants",
        "jeans": "pants",
        "shoe": "shoes",
        "shoes": "shoes",
        "sneakers": "shoes",
        "outerwear": "outerwear",
        "jacket": "outerwear",
        "coat": "outerwear",
        "accessory": "accessories",
        "accessories": "accessories",
        "bag": "accessories"
    ]

    private func extractBudgetMax(from text: String) -> Double? {
        let patterns = [
            #"(?:under|below|max|less than)\s*\$?\s*(\d{2,4})"#,
            #"\$\s*(\d{2,4})"#
        ]

        for pattern in patterns {
            if let match = firstMatch(for: pattern, in: text), let value = Double(match) {
                return value
            }
        }

        return nil
    }

    private func firstMatch(for pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard let result = regex.firstMatch(in: text, options: [], range: range), result.numberOfRanges > 1 else {
            return nil
        }

        guard let captured = Range(result.range(at: 1), in: text) else {
            return nil
        }

        return String(text[captured])
    }

    private func appendUnique(_ value: String, to array: inout [String]) {
        guard !value.isEmpty, !array.contains(value) else { return }
        array.append(value)
    }
}
