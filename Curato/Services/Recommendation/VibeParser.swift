import Foundation

protocol VibeParsing {
    func parseTags(from vibeText: String) -> Set<String>
}

struct VibeParser: VibeParsing {
    func parseTags(from vibeText: String) -> Set<String> {
        let separators = CharacterSet.alphanumerics.inverted
        let tokens = vibeText
            .lowercased()
            .components(separatedBy: separators)
            .filter { $0.count > 2 }
        return Set(tokens)
    }
}
