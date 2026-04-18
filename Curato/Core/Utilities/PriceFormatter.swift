import Foundation

enum PriceFormatter {
    static let shared: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func string(from value: Double?) -> String {
        guard let value else { return "N/A" }
        return shared.string(from: NSNumber(value: value)) ?? "N/A"
    }
}
