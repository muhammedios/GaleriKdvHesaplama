import Foundation

enum CurrencyFormatter {
    static func format(_ value: Double) -> String {
        "₺\(decimalFormatter.string(from: NSNumber(value: value)) ?? "0,00")"
    }

    static func format(_ value: Int) -> String {
        "₺\(grouped(value))"
    }

    static func grouped(_ value: Int) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func groupedInput(_ text: String) -> String {
        let digits = text.filter(\.isNumber)
        guard let value = Int(digits), value > 0 else { return digits.isEmpty ? "" : "0" }
        return grouped(value)
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }()

    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
