import Foundation
import Combine

@MainActor
final class CarStore: ObservableObject {
	@Published private(set) var cars: [Car] = []

	private let storageKey = "cars_json_v1"

	init() {
		load()
	}

	func add(_ car: Car) {
		cars.insert(car, at: 0)
		save()
	}

	func remove(at offsets: IndexSet) {
		for index in offsets.sorted(by: >) {
			guard cars.indices.contains(index) else { continue }
			cars.remove(at: index)
		}
		save()
	}

	func remove(id: UUID) {
		cars.removeAll { $0.id == id }
		save()
	}

	func replaceAll(_ cars: [Car]) {
		self.cars = cars
		save()
	}

	func car(id: UUID) -> Car? {
		cars.first { $0.id == id }
	}

	func setSold(_ isSold: Bool, id: UUID) {
		guard let index = cars.firstIndex(where: { $0.id == id }) else { return }
		cars[index].isSold = isSold
		if !isSold {
			cars[index].soldAmount = nil
		}
		save()
	}

	func setSold(_ isSold: Bool, id: UUID, soldAmount: Int?) {
		guard let index = cars.firstIndex(where: { $0.id == id }) else { return }
		cars[index].isSold = isSold
		cars[index].soldAmount = isSold ? soldAmount : nil
		save()
	}

	private func load() {
		guard
			let data = UserDefaults.standard.data(forKey: storageKey),
			let decoded = try? JSONDecoder().decode([Car].self, from: data)
		else {
			cars = []
			return
		}

		cars = decoded
	}

	private func save() {
		guard let data = try? JSONEncoder().encode(cars) else { return }
		UserDefaults.standard.set(data, forKey: storageKey)
	}
}
