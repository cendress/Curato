import Foundation

extension Double {
    var asCurrency: String {
        PriceFormatter.string(from: self)
    }
}
