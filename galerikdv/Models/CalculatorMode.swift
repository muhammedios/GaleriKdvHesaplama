import Foundation

enum CalculatorMode: String, CaseIterable, Identifiable {
    case ihaledenAlis
    case sahistanAlis
    case galeridenAlis
    case esnaftanAlis

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ihaledenAlis:
            return "İhaleden Alış"
        case .sahistanAlis:
            return "Şahıstan Alış"
        case .galeridenAlis:
            return "Esnaftan Alış"
        case .esnaftanAlis:
            return "Esnaftan Alış"
        }
    }

    var subtitle: String {
        switch self {
        case .sahistanAlis:
            return "DİREKT HESAP"
        default:
            return "KDV SEÇİLİR"
        }
    }
}
