import SwiftUI
import PhotosUI
import UIKit

struct AddCarView: View {
	let onSave: (Car) -> Void
	let onCancel: () -> Void

	@State private var plate = ""
	@State private var purchaseAmountText = ""
	@State private var isAmountFocused = false
	@State private var purchaseDate = Date()
	@State private var source: CarSource = .esnaf
	@State private var selectedVatRate: Int = 20

	@State private var selectedItems: [PhotosPickerItem] = []
	@State private var images: [CarImage] = []
	@State private var isLoadingImages = false
	@State private var isPresentingCamera = false

	@State private var showValidationAlert = false

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [Color.appScreen, Color.appSurfaceLow],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			.ignoresSafeArea()
			.contentShape(Rectangle())
			.onTapGesture { dismissKeyboard() }

			ScrollView(showsIndicators: false) {
				VStack(spacing: 16) {
					formCard
					imagesCard
					saveButton
				}
				.padding(.horizontal, 20)
				.padding(.top, 14)
				.padding(.bottom, 24)
			}
			.contentShape(Rectangle())
			.simultaneousGesture(
				TapGesture().onEnded { dismissKeyboard() }
			)
		}
		.navigationTitle("Yeni Araç Ekle")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Kapat") { onCancel() }
			}
		}
		.alert("Eksik Bilgi", isPresented: $showValidationAlert) {
			Button("Tamam", role: .cancel) { }
		} message: {
			Text(validationMessage)
		}
		.sheet(isPresented: $isPresentingCamera) {
			CameraPicker { image in
				if let jpeg = image.jpegData(compressionQuality: 0.82) {
					images.append(CarImage(jpegData: jpeg))
				}
			}
			.ignoresSafeArea()
		}
		.onChange(of: selectedItems) { newItems in
			Task { await appendImages(from: newItems) }
		}
		.onChange(of: source) { newValue in
			if newValue == .ihale || newValue == .esnaf {
				selectedVatRate = 20
			}
		}
	}

	private var formCard: some View {
		VStack(alignment: .leading, spacing: 14) {
			cardTitle("BİLGİLER")

			field(
				title: "PLAKA",
				placeholder: "34 ABC 123",
				text: Binding(
					get: { plate },
					set: { plate = $0.uppercased(with: Locale(identifier: "tr_TR")) }
				)
			)
			.textInputAutocapitalization(.characters)
			.autocorrectionDisabled()

			amountField

			DatePicker("Alış Tarihi", selection: $purchaseDate, displayedComponents: .date)
				.datePickerStyle(.compact)
				.font(.system(size: 15, weight: .semibold))
				.tint(Color.appGreen)
				.padding(.top, 4)

			sourceButtons

			if source == .ihale || source == .esnaf {
				vatButtons
			}
		}
		.cardStyle()
	}

	private var sourceButtons: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("KİMDEN ALINDI")
				.font(.system(size: 14, weight: .heavy))
				.foregroundStyle(Color.appMuted)

			HStack(spacing: 10) {
				ForEach(CarSource.uiCases) { option in
					Button {
						source = option
					} label: {
						Text(option.rawValue)
							.font(.system(size: 15, weight: .bold))
							.foregroundStyle(source == option ? Color.white : Color.appTitle)
							.frame(maxWidth: .infinity, minHeight: 44)
							.background(source == option ? Color.appGreen : Color.appSurfaceLowest)
							.overlay(
								RoundedRectangle(cornerRadius: 14, style: .continuous)
									.stroke(source == option ? Color.clear : Color.appOutlineVariant.opacity(0.45), lineWidth: 1)
							)
							.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
					}
					.buttonStyle(.plain)
				}
			}
		}
	}

	private var vatButtons: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("KDV ORANI")
				.font(.system(size: 14, weight: .heavy))
				.foregroundStyle(Color.appMuted)

			HStack(spacing: 10) {
				vatButton(rate: 1)
				vatButton(rate: 20)
			}
		}
	}

	private func vatButton(rate: Int) -> some View {
		let isSelected = selectedVatRate == rate
		return Button {
			selectedVatRate = rate
		} label: {
			Text("%\(rate)")
				.font(.system(size: 16, weight: .black, design: .rounded))
				.foregroundStyle(isSelected ? Color.white : Color.appTitle)
				.frame(maxWidth: .infinity, minHeight: 44)
				.background(isSelected ? Color.appGreen : Color.appSurfaceLowest)
				.overlay(
					RoundedRectangle(cornerRadius: 14, style: .continuous)
						.stroke(isSelected ? Color.clear : Color.appOutlineVariant.opacity(0.45), lineWidth: 1)
				)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
		}
		.buttonStyle(.plain)
	}

	private var amountField: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("ALIŞ TUTARI")
				.font(.system(size: 14, weight: .heavy))
				.foregroundStyle(Color.appMuted)

			HStack(spacing: 12) {
				Text("₺")
					.font(.system(size: 21, weight: .heavy))
					.foregroundStyle(Color.appMuted)

				FormattedNumberField(
					text: $purchaseAmountText,
					placeholder: "0",
					isFocused: $isAmountFocused,
					font: .systemFont(ofSize: 18, weight: .bold)
				)
			}
			.padding(.horizontal, 18)
			.frame(height: 52)
			.background(Color.appSurfaceLowest)
			.overlay(
				RoundedRectangle(cornerRadius: 14, style: .continuous)
					.stroke(Color.appOutlineVariant.opacity(0.45), lineWidth: 1)
			)
			.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
		}
	}

	private var imagesCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				cardTitle("NOTER SÖZLEŞMESİ (OPSİYONEL)")
				Spacer()
				if isLoadingImages {
					ProgressView()
						.tint(Color.appGreen)
				}
			}

			if images.isEmpty {
				Text("İstersen bir veya birden fazla görsel ekleyebilirsin.")
					.font(.system(size: 14, weight: .semibold))
					.foregroundStyle(Color.appMuted)
			} else {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 12) {
						ForEach(images) { img in
							if let uiImage = UIImage(data: img.jpegData) {
								Image(uiImage: uiImage)
									.resizable()
									.scaledToFill()
									.frame(width: 92, height: 92)
									.clipped()
									.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
									.overlay(
										RoundedRectangle(cornerRadius: 14, style: .continuous)
											.stroke(Color.appOutlineVariant.opacity(0.40), lineWidth: 1)
									)
							}
						}
					}
					.padding(.vertical, 4)
				}
			}

			PhotosPicker(selection: $selectedItems, maxSelectionCount: 8, matching: .images) {
				HStack {
					Image(systemName: "photo.on.rectangle.angled")
						.font(.system(size: 16, weight: .semibold))
					Text(images.isEmpty ? "Galeriden Seç" : "Galeriden Seç (+)")
						.font(.system(size: 15, weight: .bold))
					Spacer()
					Image(systemName: "plus")
						.font(.system(size: 14, weight: .bold))
				}
				.foregroundStyle(Color.appTitle)
				.padding(.horizontal, 16)
				.frame(height: 46)
				.background(Color.appSurfaceLowest)
				.overlay(
					RoundedRectangle(cornerRadius: 14, style: .continuous)
						.stroke(Color.appOutlineVariant.opacity(0.45), lineWidth: 1)
				)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			}

			Button {
				isPresentingCamera = true
			} label: {
				HStack {
					Image(systemName: "camera")
						.font(.system(size: 16, weight: .semibold))
					Text("Kamera")
						.font(.system(size: 15, weight: .bold))
					Spacer()
					Image(systemName: "plus")
						.font(.system(size: 14, weight: .bold))
				}
				.foregroundStyle(Color.appTitle)
				.padding(.horizontal, 16)
				.frame(height: 46)
				.background(Color.appSurfaceLowest)
				.overlay(
					RoundedRectangle(cornerRadius: 14, style: .continuous)
						.stroke(Color.appOutlineVariant.opacity(0.45), lineWidth: 1)
				)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			}
			.buttonStyle(.plain)
		}
		.cardStyle()
	}

	private var saveButton: some View {
		Button {
			guard isValid else {
				showValidationAlert = true
				return
			}

			let amount = Int(purchaseAmountText.filter(\.isNumber)) ?? 0
			let actualSource: CarSource = source

			var car = Car(
				plate: plate.trimmingCharacters(in: .whitespacesAndNewlines),
				purchaseAmount: amount,
				purchaseDate: purchaseDate,
				source: actualSource,
				vatRate: (source == .ihale || source == .esnaf) ? selectedVatRate : nil,
				note: nil,
				contractImages: images
			)

			car.plate = car.plate.replacingOccurrences(of: "  ", with: " ")
			onSave(car)
		} label: {
			HStack {
				Text("Kaydet")
					.font(.system(size: 16, weight: .bold))
				Spacer()
				Image(systemName: "checkmark")
					.font(.system(size: 14, weight: .bold))
			}
			.foregroundStyle(Color.white)
			.padding(.horizontal, 18)
			.frame(height: 52)
			.background(Color.appGreen)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(color: Color.appGreen.opacity(0.22), radius: 16, y: 10)
		}
		.buttonStyle(.plain)
		.padding(.top, 2)
	}

	private var isValid: Bool {
		!plate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
		!(purchaseAmountText.filter(\.isNumber).isEmpty)
	}

	private var validationMessage: String {
		if plate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Plaka zorunludur." }
		if purchaseAmountText.filter(\.isNumber).isEmpty { return "Alış tutarı zorunludur." }
		return "Eksik bilgi."
	}

	private func field(title: String, placeholder: String, text: Binding<String>) -> some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(title)
				.font(.system(size: 14, weight: .heavy))
				.foregroundStyle(Color.appMuted)

			TextField(placeholder, text: text)
				.font(.system(size: 16, weight: .bold))
				.foregroundStyle(Color.appInputText)
				.padding(.horizontal, 16)
				.frame(height: 52)
				.background(Color.appSurfaceLowest)
				.overlay(
					RoundedRectangle(cornerRadius: 14, style: .continuous)
						.stroke(Color.appOutlineVariant.opacity(0.45), lineWidth: 1)
				)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
		}
	}

	private func cardTitle(_ title: String) -> some View {
		Text(title)
			.font(.system(size: 14, weight: .heavy))
			.tracking(2.2)
			.foregroundStyle(Color.appMuted)
	}

	@MainActor
	private func appendImages(from items: [PhotosPickerItem]) async {
		guard !items.isEmpty else { return }
		isLoadingImages = true
		defer { isLoadingImages = false }

		for item in items {
			if let data = try? await item.loadTransferable(type: Data.self) {
				if let jpeg = toJpegData(data: data) {
					images.append(CarImage(jpegData: jpeg))
				}
			}
		}
		selectedItems = []
	}

	private func toJpegData(data: Data) -> Data? {
		guard let uiImage = UIImage(data: data) else { return nil }
		return uiImage.jpegData(compressionQuality: 0.82)
	}

	private func dismissKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}

private struct CameraPicker: UIViewControllerRepresentable {
	let onImage: (UIImage) -> Void

	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.sourceType = .camera
		picker.allowsEditing = false
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator(onImage: onImage)
	}

	final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		let onImage: (UIImage) -> Void

		init(onImage: @escaping (UIImage) -> Void) {
			self.onImage = onImage
		}

		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let image = info[.originalImage] as? UIImage {
				onImage(image)
			}
			picker.dismiss(animated: true)
		}

		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			picker.dismiss(animated: true)
		}
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
