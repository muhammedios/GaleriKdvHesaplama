import SwiftUI

struct CarDetailView: View {
	@EnvironmentObject private var store: CarStore
	@EnvironmentObject private var appState: AppState

	let carID: UUID
	@State private var isPresentingViewer = false
	@State private var viewerIndex = 0
	@State private var showUnsellConfirm = false

	var body: some View {
		Group {
			if let car {
				content(car)
			} else {
				Text("Araç bulunamadı.")
					.font(.system(size: 16, weight: .bold))
					.foregroundStyle(Color.appTitle)
			}
		}
	}

	private var car: Car? {
		store.car(id: carID)
	}

	private func content(_ car: Car) -> some View {
		ZStack {
			LinearGradient(
				colors: [Color.appScreen, Color.appSurfaceLow],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(spacing: 18) {
					headerCard(car)
					infoCard(car)
					imagesCard(car)
				}
				.padding(.horizontal, 20)
				.padding(.top, 14)
				.padding(.bottom, 32)
			}
		}
		.navigationTitle(car.plate)
		.navigationBarTitleDisplayMode(.inline)
		.fullScreenCover(isPresented: $isPresentingViewer) {
			ImageViewer(
				images: car.contractImages.compactMap { UIImage(data: $0.jpegData) },
				startIndex: viewerIndex
			)
		}
		.safeAreaInset(edge: .bottom) {
			saleBar(car)
		}
		.alert("Satış geri alınsın mı?", isPresented: $showUnsellConfirm) {
			Button("Vazgeç", role: .cancel) { }
			Button("Geri Al") {
				store.setSold(false, id: carID, soldAmount: nil)
				appState.carsFilter = .active
			}
		} message: {
			Text("\(car.plate) plakalı aracın satışını geri almak istiyor musunuz?")
		}
	}

	private func headerCard(_ car: Car) -> some View {
		HStack(spacing: 12) {
			ZStack {
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.fill(Color.appGreen.opacity(0.10))
					.frame(width: 54, height: 54)
				Image(systemName: "car.fill")
					.font(.system(size: 20, weight: .bold))
					.foregroundStyle(Color.appGreen)
			}

			VStack(alignment: .leading, spacing: 6) {
				Text(car.plate)
					.font(.system(size: 22, weight: .black))
					.foregroundStyle(Color.appTitle)

				HStack(spacing: 8) {
					Text(car.source.rawValue.uppercased())
						.font(.system(size: 11, weight: .heavy))
						.padding(.horizontal, 8)
						.padding(.vertical, 5)
						.foregroundStyle(Color.appGreenDark)
						.background(Color.appGreen.opacity(0.10))
						.clipShape(Capsule())

					if (car.source == .ihale || car.source == .esnaf), let vatRate = car.vatRate {
						Text("KDV %\(vatRate)")
							.font(.system(size: 11, weight: .heavy))
							.padding(.horizontal, 8)
							.padding(.vertical, 5)
							.foregroundStyle(Color.appTitle.opacity(0.88))
							.background(Color.appOutlineVariant.opacity(0.22))
							.clipShape(Capsule())
					}
				}
			}

			Spacer(minLength: 0)
		}
		.cardStyle()
	}

	private func infoCard(_ car: Car) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			cardTitle("BİLGİLER")

			infoRow(title: "Alış Tarihi", value: dateFormatter.string(from: car.purchaseDate), systemImage: "calendar")
			infoRow(title: "Alış Tutarı", value: CurrencyFormatter.format(car.purchaseAmount), systemImage: "banknote")
			if car.isSold, let soldAmount = car.soldAmount {
				infoRow(title: "Satış Tutarı", value: CurrencyFormatter.format(soldAmount), systemImage: "tag.fill")
			}
		}
		.cardStyle()
	}

	private func imagesCard(_ car: Car) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			cardTitle("NOTER SÖZLEŞMESİ")

			if car.contractImages.isEmpty {
				Text("Bu araç için sözleşme görseli eklenmedi.")
					.font(.system(size: 14, weight: .semibold))
					.foregroundStyle(Color.appMuted)
			} else {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 12) {
						ForEach(Array(car.contractImages.enumerated()), id: \.element.id) { index, img in
							if let uiImage = UIImage(data: img.jpegData) {
								Button {
									viewerIndex = index
									isPresentingViewer = true
								} label: {
									Image(uiImage: uiImage)
										.resizable()
										.scaledToFill()
										.frame(width: 120, height: 120)
										.clipped()
										.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
										.overlay(
											RoundedRectangle(cornerRadius: 18, style: .continuous)
												.stroke(Color.appOutlineVariant.opacity(0.35), lineWidth: 1)
										)
								}
								.buttonStyle(.plain)
							}
						}
					}
					.padding(.vertical, 4)
				}
			}
		}
		.cardStyle()
	}

	private func infoRow(title: String, value: String, systemImage: String) -> some View {
		HStack(spacing: 10) {
			Image(systemName: systemImage)
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(Color.appGreen)
				.frame(width: 24)

			VStack(alignment: .leading, spacing: 3) {
				Text(title.uppercased())
					.font(.system(size: 12, weight: .heavy))
					.foregroundStyle(Color.appMuted)
				Text(value)
					.font(.system(size: 16, weight: .bold))
					.foregroundStyle(Color.appTitle)
			}

			Spacer(minLength: 0)
		}
		.padding(.vertical, 6)
	}

	private func cardTitle(_ title: String) -> some View {
		Text(title)
			.font(.system(size: 14, weight: .heavy))
			.tracking(2.2)
			.foregroundStyle(Color.appMuted)
	}

	private func saleBar(_ car: Car) -> some View {
		VStack(spacing: 0) {
			Button {
				if car.isSold {
					showUnsellConfirm = true
				} else {
					appState.pendingSaleCarID = carID
					appState.selectedTab = .home
				}
			} label: {
				HStack {
					Text(car.isSold ? "Satışı Geri Al" : "Aracı Sat")
						.font(.system(size: 18, weight: .black))
					Spacer(minLength: 0)
					Image(systemName: car.isSold ? "arrow.uturn.backward" : "arrow.right")
						.font(.system(size: 16, weight: .bold))
				}
				.foregroundStyle(.white)
				.padding(.horizontal, 18)
				.frame(maxWidth: .infinity, minHeight: 52)
				.background(car.isSold ? Color.appTitle.opacity(0.65) : Color.appGreen)
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
				.shadow(color: (car.isSold ? Color.black.opacity(0.10) : Color.appGreen.opacity(0.22)), radius: 14, y: 8)
			}
			.buttonStyle(.plain)
			.padding(.horizontal, 20)
			.padding(.top, 6)
			.padding(.bottom, 10)
		}
		.background(Color.clear)
	}

	private var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "tr_TR")
		formatter.dateFormat = "dd.MM.yyyy"
		return formatter
	}
}

private extension View {
	func cardStyle() -> some View {
		self
			.padding(18)
			.background(Color.appSurfaceLowest.opacity(0.92))
			.overlay(
				RoundedRectangle(cornerRadius: 26, style: .continuous)
					.stroke(Color.appOutlineVariant.opacity(0.35), lineWidth: 1)
			)
			.clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
			.shadow(color: Color.appGreenDark.opacity(0.09), radius: 20, y: 10)
	}
}
