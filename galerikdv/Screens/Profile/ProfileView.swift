import SwiftUI
import AuthenticationServices
import StoreKit
import UIKit
import Combine

struct ProfileView: View {
	@Environment(\.openURL) private var openURL

	@State private var showNotImplementedAlert = false
	@StateObject private var appleSignInHandler = AppleSignInHandler()

	@AppStorage("profile_google_signed_in") private var isGoogleSignedIn = false
	@AppStorage("profile_apple_signed_in") private var isAppleSignedIn = false
	@AppStorage("profile_biometric_lock_enabled") private var isBiometricLockEnabled = false

	private let privacyURL = URL(string: "https://muhammedylmz.com/hesaplama/gizlilik")
	private let termsURL = URL(string: "https://muhammedylmz.com/hesaplama/kosullar")
	private let howToVideoURL = URL(string: "https://www.youtube.com/watch?v=VIDEO_ID")

	var body: some View {
		NavigationStack {
			ZStack {
				LinearGradient(
					colors: [Color.appScreen, Color.appSurfaceLow],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.ignoresSafeArea()

				ScrollView(showsIndicators: false) {
					VStack(spacing: 18) {
						profileHeader
						signInCard
						premiumCard
						privacySecurityCard
						actionsCard
					}
					.padding(.horizontal, 20)
					.padding(.top, 14)
					.padding(.bottom, 32)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Profil")
						.font(.system(size: 22, weight: .black))
						.foregroundStyle(Color.appTitle)
				}
			}
			.alert("Bilgi", isPresented: $showNotImplementedAlert) {
				Button("Tamam", role: .cancel) { }
			} message: {
				Text("Bu özellik şu an sadece arayüz olarak hazır. İstersen sonraki adımda Apple/Google girişini entegre edelim.")
			}
		}
	}

	private var profileHeader: some View {
		HStack(spacing: 14) {
			ZStack {
				Circle()
					.fill(Color.appGreen.opacity(0.12))
					.frame(width: 54, height: 54)
				Image(systemName: "person.fill")
					.font(.system(size: 22, weight: .bold))
					.foregroundStyle(Color.appGreen)
			}

			VStack(alignment: .leading, spacing: 4) {
				Text(isSignedIn ? "Hoş geldin" : "Giriş Yap")
					.font(.system(size: 20, weight: .black))
					.foregroundStyle(Color.appTitle)

				Text(isSignedIn ? "Hesabını yönet" : "Apple veya Google ile devam et")
					.font(.system(size: 14, weight: .semibold))
					.foregroundStyle(Color.appMuted)
			}

			Spacer(minLength: 0)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var signInCard: some View {
		VStack(alignment: .leading, spacing: 14) {
			cardTitle("GİRİŞ")

			Button {
				appleSignInHandler.start { result in
					switch result {
					case .success:
						isAppleSignedIn = true
						showNotImplementedAlert = true
					case .failure:
						showNotImplementedAlert = true
					}
				}
			} label: {
				HStack {
					Spacer(minLength: 0)
					HStack(spacing: 10) {
						Image(systemName: "apple.logo")
							.font(.system(size: 18, weight: .semibold))
						Text("Apple ile giriş")
							.font(.system(size: 16, weight: .semibold))
					}
					.fixedSize(horizontal: true, vertical: false)
					Spacer(minLength: 0)
				}
				.foregroundStyle(Color.white)
				.frame(height: 48)
				.background(Color.black)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			}
			.buttonStyle(.plain)

			Button {
				isGoogleSignedIn = true
				showNotImplementedAlert = true
			} label: {
				HStack {
					Spacer(minLength: 0)
					HStack(spacing: 12) {
						googleLogo
							.frame(width: 20, height: 20)

						(
							Text("Google")
								.font(.system(size: 15, weight: .semibold))
							+
							Text(" ile giriş")
								.font(.system(size: 15, weight: .medium))
						)
					}
					.fixedSize(horizontal: true, vertical: false)
					Spacer(minLength: 0)
				}
				.foregroundStyle(Color(red: 0.122, green: 0.122, blue: 0.122))
				.padding(.horizontal, 18)
				.frame(height: 48)
				.background(Color.white)
				.overlay(
					RoundedRectangle(cornerRadius: 14, style: .continuous)
						.stroke(Color(red: 0.455, green: 0.467, blue: 0.459), lineWidth: 1)
				)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			}
			.buttonStyle(.plain)

			if isSignedIn {
				Button(role: .destructive) {
					isAppleSignedIn = false
					isGoogleSignedIn = false
				} label: {
					Text("Çıkış Yap")
						.font(.system(size: 15, weight: .bold))
						.frame(maxWidth: .infinity, minHeight: 44)
						.background(Color.appSurfaceLowest)
						.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
						.overlay(
							RoundedRectangle(cornerRadius: 14, style: .continuous)
								.stroke(Color.appOutlineVariant.opacity(0.40), lineWidth: 1)
						)
				}
				.buttonStyle(.plain)
			}
		}
		.cardStyle()
	}

	private var premiumCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				cardTitle("PREMIUM")
				Spacer()
				Text("Önerilen")
					.font(.system(size: 12, weight: .heavy))
					.padding(.horizontal, 10)
					.padding(.vertical, 6)
					.foregroundStyle(Color.white)
					.background(Color.appGreen)
					.clipShape(Capsule())
			}

			Text("Araç maliyetlerini takip et, hızlı işlemlerle zamandan kazan.")
				.font(.system(size: 14, weight: .semibold))
				.foregroundStyle(Color.appMuted)

			VStack(alignment: .leading, spacing: 10) {
				premiumRow("Araç alış maliyeti takibi")
				premiumRow("Çoklu Araç Ekleme")
				premiumRow("Hızlı KDV hesaplama")
			}

			Button {
				showNotImplementedAlert = true
			} label: {
				HStack {
					Text("Premium’a Geç")
						.font(.system(size: 16, weight: .bold))
					Spacer()
					Image(systemName: "chevron.right")
						.font(.system(size: 14, weight: .bold))
				}
				.foregroundStyle(Color.white)
				.padding(.horizontal, 16)
				.frame(height: 48)
				.background(
					LinearGradient(
						colors: [Color.appGreen, Color.appGreenDark],
						startPoint: .leading,
						endPoint: .trailing
					)
				)
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
				.shadow(color: Color.appGreen.opacity(0.22), radius: 16, y: 10)
			}
			.buttonStyle(.plain)
		}
		.cardStyle()
	}

	private var privacySecurityCard: some View {
		VStack(alignment: .leading, spacing: 14) {
			cardTitle("GİZLİLİK & GÜVENLİK")

			Toggle(isOn: $isBiometricLockEnabled) {
				rowLabel("Face ID / Touch ID Kilidi", systemImage: "faceid")
			}
			.tint(Color.appGreen)

			Button {
				if let privacyURL {
					openURL(privacyURL)
				}
			} label: {
				rowChevron("Gizlilik Politikası", systemImage: "lock.shield")
			}
			.buttonStyle(.plain)

			Button {
				if let termsURL {
					openURL(termsURL)
				}
			} label: {
				rowChevron("Kullanım Koşulları", systemImage: "doc.text")
			}
			.buttonStyle(.plain)
		}
		.cardStyle()
	}

	private var actionsCard: some View {
		VStack(alignment: .leading, spacing: 14) {
			cardTitle("DİĞER")

			NavigationLink {
				CalculationPolicyView()
			} label: {
				rowChevron("Hesaplama Esasları", systemImage: "doc.text.magnifyingglass")
			}

			Button {
				if let howToVideoURL {
					openURL(howToVideoURL)
				} else {
					showNotImplementedAlert = true
				}
			} label: {
				rowChevron("Kullanım Videosu", systemImage: "play.rectangle")
			}
			.buttonStyle(.plain)

			Button {
				if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
					SKStoreReviewController.requestReview(in: scene)
				} else {
					showNotImplementedAlert = true
				}
			} label: {
				rowChevron("Puanla", systemImage: "star.bubble")
			}
			.buttonStyle(.plain)

			Button {
				showNotImplementedAlert = true
			} label: {
				rowChevron("Destek", systemImage: "questionmark.circle")
			}
			.buttonStyle(.plain)

			Button {
				UIPasteboard.general.string = "Galeri KDV Hesaplama"
			} label: {
				rowChevron("Uygulamayı Paylaş", systemImage: "square.and.arrow.up")
			}
			.buttonStyle(.plain)
		}
		.cardStyle()
	}

	private var isSignedIn: Bool {
		isAppleSignedIn || isGoogleSignedIn
	}

	private func cardTitle(_ title: String) -> some View {
		Text(title)
			.font(.system(size: 14, weight: .heavy))
			.tracking(2.2)
			.foregroundStyle(Color.appMuted)
	}

	private func rowLabel(_ title: String, systemImage: String) -> some View {
		HStack(spacing: 10) {
			Image(systemName: systemImage)
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(Color.appGreen)
				.frame(width: 24)

			Text(title)
				.font(.system(size: 15, weight: .semibold))
				.foregroundStyle(Color.appTitle)
		}
	}

	private func rowChevron(_ title: String, systemImage: String) -> some View {
		HStack(spacing: 10) {
			Image(systemName: systemImage)
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(Color.appGreen)
				.frame(width: 24)

			Text(title)
				.font(.system(size: 15, weight: .semibold))
				.foregroundStyle(Color.appTitle)

			Spacer(minLength: 0)

			Image(systemName: "chevron.right")
				.font(.system(size: 13, weight: .bold))
				.foregroundStyle(Color.appMuted.opacity(0.65))
		}
		.padding(.vertical, 8)
		.contentShape(Rectangle())
	}

	private func premiumRow(_ text: String) -> some View {
		HStack(spacing: 10) {
			Image(systemName: "checkmark.seal.fill")
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(Color.appGreen)
			Text(text)
				.font(.system(size: 14, weight: .semibold))
				.foregroundStyle(Color.appTitle.opacity(0.92))
			Spacer(minLength: 0)
		}
	}

	private var googleLogo: some View {
		Group {
			if let uiImage = UIImage(named: "google_g") {
				Image(uiImage: uiImage)
					.resizable()
					.renderingMode(.original)
					.scaledToFit()
			} else {
				ZStack {
					Circle()
						.fill(Color.white)
						overlay {
							Circle().stroke(Color(red: 0.455, green: 0.467, blue: 0.459), lineWidth: 1)
						}
					Text("G")
						.font(.system(size: 13, weight: .black))
						.foregroundStyle(Color.appTitle)
				}
			}
		}
	}
}

struct ProfileView_Previews: PreviewProvider {
	static var previews: some View {
		ProfileView()
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

private final class AppleSignInHandler: NSObject, ObservableObject {
	enum SignInError: Error {
		case cancelled
		case unknown
	}

	let objectWillChange = ObservableObjectPublisher()

	private var completion: ((Result<Void, Error>) -> Void)?

	func start(completion: @escaping (Result<Void, Error>) -> Void) {
		self.completion = completion

		let request = ASAuthorizationAppleIDProvider().createRequest()
		request.requestedScopes = [.fullName, .email]

		let controller = ASAuthorizationController(authorizationRequests: [request])
		controller.delegate = self
		controller.presentationContextProvider = self
		controller.performRequests()
	}
}

extension AppleSignInHandler: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		completion?(.success(()))
		completion = nil
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		let nsError = error as NSError
		if nsError.domain == ASAuthorizationError.errorDomain,
		   nsError.code == ASAuthorizationError.canceled.rawValue {
			completion?(.failure(SignInError.cancelled))
		} else {
			completion?(.failure(error))
		}
		completion = nil
	}
}

extension AppleSignInHandler: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		let scenes = UIApplication.shared.connectedScenes
		let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
		let window = windowScene?.windows.first { $0.isKeyWindow } ?? windowScene?.windows.first
		return window ?? ASPresentationAnchor()
	}
}
