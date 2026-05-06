import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var selectedMode: CalculatorMode
    @Published var selectedVatRate: Int
    @Published var isSpecialMatrahSelected: Bool
    @Published var buyPrice: String
    @Published var sellPrice: String
    @Published var outputValue: Double

    init(
        selectedMode: CalculatorMode = .ihaledenAlis,
        selectedVatRate: Int = 20,
        isSpecialMatrahSelected: Bool = false,
        buyPrice: String = "",
        sellPrice: String = "",
        outputValue: Double = 0
    ) {
        self.selectedMode = selectedMode
        self.selectedVatRate = selectedVatRate
        self.isSpecialMatrahSelected = isSpecialMatrahSelected
        self.buyPrice = buyPrice
        self.sellPrice = sellPrice
        self.outputValue = outputValue
    }

    func reset() {
        buyPrice = ""
        sellPrice = ""
        outputValue = 0
    }

    func calculate() {
        outputValue = previewValue
    }

    func updateBuyPrice(_ text: String) {
        buyPrice = CurrencyFormatter.groupedInput(text)
    }

    func updateSellPrice(_ text: String) {
        sellPrice = CurrencyFormatter.groupedInput(text)
    }

	func applySalePrefill(from car: Car) {
		switch car.source {
		case .ihale:
			selectedMode = .ihaledenAlis
		case .esnaf:
			selectedMode = .esnaftanAlis
		case .sahis:
			selectedMode = .sahistanAlis
		case .diger:
			selectedMode = .ihaledenAlis
		}

		isSpecialMatrahSelected = false
		if let vatRate = car.vatRate, selectedMode != .sahistanAlis {
			selectedVatRate = vatRate
		} else if selectedMode == .sahistanAlis {
			selectedVatRate = 20
		}

		let groupedPurchase = CurrencyFormatter.groupedInput(String(car.purchaseAmount))
		switch selectedMode {
		case .sahistanAlis:
			buyPrice = groupedPurchase
			sellPrice = ""
		case .ihaledenAlis, .esnaftanAlis:
			sellPrice = groupedPurchase
		}
	}

    private var previewValue: Double {
        let buy = Double(buyPrice.filter(\.isNumber)) ?? 0
        let sell = Double(sellPrice.filter(\.isNumber)) ?? 0
        let vatRate = Double(selectedVatRate)
        let vatMultiplier = 1 + (vatRate / 100)

        let margin = sell - buy
        let sahistanVatMultiplier = 1.20

        switch selectedMode {
        case .ihaledenAlis:
            // Ihale alis: satis tutari secilen KDV katsayisina bolunur (ornek 1.01 / 1.20).
            return sell / vatMultiplier
        case .sahistanAlis:
            // Sahistan alis: marj KDV'den arindirilip alis bedeline eklenir.
            return buy + (margin / sahistanVatMultiplier)
        case .esnaftanAlis:
            // KDV siz seceneginde satis tutari 1.01'e bolunerek hesaplanir.
            if isSpecialMatrahSelected {
                return sell / 1.01
            }
            // Esnaftan alis: ihale moduyla ayni sekilde satis tutari KDV katsayisina bolunur.
            return sell / vatMultiplier
        }
    }
}
