import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
	enum Tab: Hashable {
		case home
		case cars
		case profile
	}

	@Published var selectedTab: Tab = .home
	@Published var carsFilter: CarListFilter = .active

	@Published var pendingSaleCarID: UUID?
}
