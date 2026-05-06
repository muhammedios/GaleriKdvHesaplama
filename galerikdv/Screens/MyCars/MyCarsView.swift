import SwiftUI

struct MyCarsView: View {
	@EnvironmentObject private var store: CarStore
	@EnvironmentObject private var appState: AppState
	@State private var query = ""
	@State private var isPresentingAddCar = false
	@State private var deleteCandidate: Car?
	@State private var path = NavigationPath()

	var body: some View {
		NavigationStack(path: $path) {
			ZStack {
				LinearGradient(
					colors: [Color.appScreen, Color.appSurfaceLow],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.ignoresSafeArea()

					List {
						filterBar

						if filteredCars.isEmpty {
							emptyState
						} else {
						ForEach(filteredCars) { car in
							Button {
								path.append(car.id)
							} label: {
								carRow(car)
							}
							.buttonStyle(.plain)
							.listRowBackground(Color.clear)
							.listRowSeparator(.hidden)
							.listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
							.swipeActions(edge: .trailing, allowsFullSwipe: false) {
								Button(role: .destructive) {
									deleteCandidate = car
								} label: {
									Label("Sil", systemImage: "trash")
								}
								.tint(.red)
							}
						}
					}
				}
				.listStyle(.plain)
				.listRowSeparator(.hidden)
				.scrollContentBackground(.hidden)
				.background(Color.clear)
				.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Plaka ara")

				if appState.carsFilter == .active {
					fab
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationDestination(for: UUID.self) { carID in
				CarDetailView(carID: carID)
			}
			.alert("Silinsin mi?", isPresented: Binding(
				get: { deleteCandidate != nil },
				set: { newValue in
					if !newValue { deleteCandidate = nil }
				}
			)) {
				Button("Vazgeç", role: .cancel) { deleteCandidate = nil }
				Button("Sil", role: .destructive) {
					if let car = deleteCandidate {
						store.remove(id: car.id)
					}
					deleteCandidate = nil
				}
			} message: {
				Text("\(deleteCandidate?.plate ?? "") plakalı aracı silmek istiyor musunuz?")
			}
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Araçlarım")
						.font(.system(size: 22, weight: .black))
						.foregroundStyle(Color.appTitle)
				}
			}
			.sheet(isPresented: $isPresentingAddCar) {
				NavigationStack {
					AddCarView { newCar in
						store.add(newCar)
						isPresentingAddCar = false
					} onCancel: {
						isPresentingAddCar = false
					}
				}
				.presentationDetents([.large])
			}
		}
	}

		private var filteredCars: [Car] {
			let base = appState.carsFilter.apply(to: store.cars)
			let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
			guard !trimmed.isEmpty else { return base }
			return base.filter { $0.plate.localizedCaseInsensitiveContains(trimmed) }
		}

		private var filterBar: some View {
			HStack(spacing: 12) {
				filterButton(.active)
				filterButton(.sold)
			}
			.listRowBackground(Color.clear)
			.listRowSeparator(.hidden)
			.listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 10, trailing: 12))
		}

		private func filterButton(_ value: CarListFilter) -> some View {
			let isSelected = appState.carsFilter == value
			return Button {
				appState.carsFilter = value
			} label: {
				Text(value.title)
					.font(.system(size: 14, weight: .heavy))
					.foregroundStyle(isSelected ? Color.white : Color.appTitle)
					.frame(maxWidth: .infinity, minHeight: 42)
					.background(isSelected ? Color.appGreen : Color.appSurfaceLowest)
					.overlay(
						RoundedRectangle(cornerRadius: 16, style: .continuous)
							.stroke(isSelected ? Color.clear : Color.appOutlineVariant.opacity(0.35), lineWidth: 1)
					)
					.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
					.shadow(color: isSelected ? Color.appGreen.opacity(0.18) : Color.clear, radius: 12, y: 6)
			}
			.buttonStyle(.plain)
		}

	private var emptyState: some View {
		VStack(spacing: 12) {
			Image(systemName: "car.fill")
				.font(.system(size: 24, weight: .bold))
				.foregroundStyle(Color.appGreen)

			Text(appState.carsFilter == .sold ? "Satılan araç yok" : "Henüz araç eklenmedi")
				.font(.system(size: 16, weight: .bold))
				.foregroundStyle(Color.appTitle)

			if appState.carsFilter != .sold {
				Text("Sağ alttaki + butonundan yeni araç ekleyebilirsin.")
					.font(.system(size: 14, weight: .semibold))
					.foregroundStyle(Color.appMuted)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 18)
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 28)
		.listRowBackground(Color.clear)
		.listRowSeparator(.hidden)
	}

	private func carRow(_ car: Car) -> some View {
		HStack(spacing: 12) {
			ZStack {
				RoundedRectangle(cornerRadius: 14, style: .continuous)
					.fill(Color.appGreen.opacity(0.10))
					.frame(width: 46, height: 46)
				Image(systemName: "car.fill")
					.font(.system(size: 18, weight: .bold))
					.foregroundStyle(Color.appGreen)
			}

			VStack(alignment: .leading, spacing: 6) {
				HStack(spacing: 8) {
					Text(car.plate)
						.font(.system(size: 18, weight: .black))
						.foregroundStyle(Color.appTitle)
						.lineLimit(1)

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
							.foregroundStyle(Color.appGreenDark)
							.background(Color.appGreen.opacity(0.10))
							.clipShape(Capsule())
					}

					Spacer(minLength: 0)
				}

				HStack(spacing: 8) {
					Image(systemName: "calendar")
						.font(.system(size: 12, weight: .semibold))
						.foregroundStyle(Color.appMuted.opacity(0.9))

					Text(dateFormatter.string(from: car.purchaseDate))
						.font(.system(size: 13, weight: .semibold))
						.foregroundStyle(Color.appMuted)

					Spacer(minLength: 0)

					Text(CurrencyFormatter.format(car.purchaseAmount))
						.font(.system(size: 13, weight: .bold))
						.foregroundStyle(Color.appGreenDark)
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, 12)
		.padding(.horizontal, 12)
		.background(Color.appSurfaceLowest)
		.overlay(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.stroke(Color.appOutlineVariant.opacity(0.35), lineWidth: 1)
		)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
		.shadow(color: Color.appGreenDark.opacity(0.05), radius: 14, y: 6)
	}

	private var fab: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Button {
					guard appState.carsFilter == .active else { return }
					isPresentingAddCar = true
				} label: {
					Image(systemName: "plus")
						.font(.system(size: 22, weight: .black))
						.foregroundStyle(Color.white)
						.frame(width: 66, height: 66)
						.background(Color.appGreen)
						.clipShape(Circle())
						.shadow(color: Color.appGreen.opacity(0.30), radius: 22, y: 12)
				}
				.buttonStyle(.plain)
				.padding(.trailing, 18)
				.padding(.bottom, 18)
			}
		}
	}

	private var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "tr_TR")
		formatter.dateFormat = "dd.MM.yyyy"
		return formatter
	}
}

struct MyCarsView_Previews: PreviewProvider {
	static var previews: some View {
		MyCarsView()
			.environmentObject(CarStore())
			.environmentObject(AppState())
	}
}
