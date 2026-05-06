import Foundation

struct Car: Identifiable, Codable, Equatable {
	var id: UUID
	var plate: String
	var purchaseAmount: Int
	var purchaseDate: Date
	var source: CarSource
	var vatRate: Int?
	var isSold: Bool
	var soldAmount: Int?
	var note: String?
	var contractImages: [CarImage]

	init(
		id: UUID = UUID(),
		plate: String,
		purchaseAmount: Int,
		purchaseDate: Date,
		source: CarSource,
		vatRate: Int? = nil,
		isSold: Bool = false,
		soldAmount: Int? = nil,
		note: String? = nil,
		contractImages: [CarImage] = []
	) {
		self.id = id
		self.plate = plate
		self.purchaseAmount = purchaseAmount
		self.purchaseDate = purchaseDate
		self.source = source
		self.vatRate = vatRate
		self.isSold = isSold
		self.soldAmount = soldAmount
		self.note = note
		self.contractImages = contractImages
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case plate
		case purchaseAmount
		case purchaseDate
		case source
		case vatRate
		case isSold
		case soldAmount
		case note
		case contractImages
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		plate = try container.decode(String.self, forKey: .plate)
		purchaseAmount = try container.decode(Int.self, forKey: .purchaseAmount)
		purchaseDate = try container.decode(Date.self, forKey: .purchaseDate)
		source = try container.decode(CarSource.self, forKey: .source)
		vatRate = try container.decodeIfPresent(Int.self, forKey: .vatRate)
		isSold = try container.decodeIfPresent(Bool.self, forKey: .isSold) ?? false
		soldAmount = try container.decodeIfPresent(Int.self, forKey: .soldAmount)
		note = try container.decodeIfPresent(String.self, forKey: .note)
		contractImages = try container.decodeIfPresent([CarImage].self, forKey: .contractImages) ?? []
	}
}

extension Car: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

enum CarSource: String, Codable, CaseIterable, Identifiable {
	case ihale = "İhale"
	case esnaf = "Esnaf"
	case sahis = "Şahıs"
	case diger = "Diğer"

	var id: String { rawValue }

	static var uiCases: [CarSource] { [.ihale, .esnaf, .sahis] }
}

struct CarImage: Identifiable, Codable, Equatable {
	var id: UUID
	var jpegData: Data

	init(id: UUID = UUID(), jpegData: Data) {
		self.id = id
		self.jpegData = jpegData
	}
}
