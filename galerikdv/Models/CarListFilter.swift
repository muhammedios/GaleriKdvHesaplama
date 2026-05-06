import Foundation

enum CarListFilter: String, CaseIterable, Identifiable {
	case sold
	case active

	var id: String { rawValue }

	var title: String {
		switch self {
		case .sold:
			return "Satılan"
		case .active:
			return "Araçlar"
		}
	}

	func apply(to cars: [Car]) -> [Car] {
		switch self {
		case .sold:
			return cars.filter { $0.isSold }
		case .active:
			return cars.filter { !$0.isSold }
		}
	}
}

