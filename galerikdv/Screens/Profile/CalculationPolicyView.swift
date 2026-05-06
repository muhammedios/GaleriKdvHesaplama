import SwiftUI

struct CalculationPolicyView: View {
	@Environment(\.openURL) private var openURL

	private let decisionDate = "06.05.2026"
	private let sourceItems: [(title: String, url: URL?)] = [
		("Gelir İdaresi Başkanlığı", URL(string: "https://www.gib.gov.tr")),
		("Resmî Gazete", URL(string: "https://www.resmigazete.gov.tr"))
	]

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [Color.appScreen, Color.appSurfaceLow],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(spacing: 18) {
					headerCard
					rulesCard
					sourcesCard
					disclaimerCard
				}
				.padding(.horizontal, 20)
				.padding(.top, 14)
				.padding(.bottom, 32)
			}
		}
		.navigationTitle("Hesaplama Esasları")
		.navigationBarTitleDisplayMode(.inline)
	}

	private var headerCard: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("KAYNAK & TARİH")
				.font(.system(size: 14, weight: .heavy))
				.tracking(2.2)
				.foregroundStyle(Color.appMuted)

			HStack(spacing: 12) {
				Image(systemName: "calendar")
					.font(.system(size: 16, weight: .semibold))
					.foregroundStyle(Color.appGreen)
					.frame(width: 24)

				Text("Esas alınan tarih: \(decisionDate)")
					.font(.system(size: 15, weight: .semibold))
					.foregroundStyle(Color.appTitle)
			}

			Text("Bu ekranda, uygulamadaki hesaplama seçeneklerinin hangi varsayımlar ve genel bilgilerle oluşturulduğu özetlenir.")
				.font(.system(size: 14, weight: .semibold))
				.foregroundStyle(Color.appMuted)
		}
		.cardStyle()
	}

	private var rulesCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("HESAPLAMA")
				.font(.system(size: 14, weight: .heavy))
				.tracking(2.2)
				.foregroundStyle(Color.appMuted)

			ruleRow(
				title: "İhaleden Alış",
				body: "Satış tutarı, seçilen KDV oranına göre KDV katsayısına bölünerek hesaplanır (ör. %20 için 1,20)."
			)

			ruleRow(
				title: "Şahıstan Alış (Direkt Hesap)",
				body: "Alış ve satış birlikte girilir. Marj, %20 KDV’den arındırılarak alış bedeline eklenir."
			)

			ruleRow(
				title: "Esnaftan Alış",
				body: "Satış tutarı, seçilen KDV oranına göre KDV katsayısına bölünerek hesaplanır. “KDV’siz” seçildiğinde satış tutarı 1,01’e bölünür."
			)

			Text("Not: Uygulamadaki sonuçlar, girdiğiniz tutarlara göre otomatik hesaplama sağlar; resmi/bağlayıcı hesaplama yerine geçmez.")
				.font(.system(size: 13, weight: .semibold))
				.foregroundStyle(Color.appMuted)
				.padding(.top, 2)
		}
		.cardStyle()
	}

	private func ruleRow(title: String, body: String) -> some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.system(size: 16, weight: .bold))
				.foregroundStyle(Color.appTitle)

			Text(body)
				.font(.system(size: 14, weight: .semibold))
				.foregroundStyle(Color.appMuted)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, 6)
	}

	private var sourcesCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("KAYNAKLAR")
				.font(.system(size: 14, weight: .heavy))
				.tracking(2.2)
				.foregroundStyle(Color.appMuted)

			ForEach(Array(sourceItems.enumerated()), id: \.offset) { _, item in
				Button {
					if let url = item.url {
						openURL(url)
					}
				} label: {
					HStack(spacing: 10) {
						Image(systemName: "link")
							.font(.system(size: 16, weight: .semibold))
							.foregroundStyle(Color.appGreen)
							.frame(width: 24)

						Text(item.title)
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
				.buttonStyle(.plain)
				.disabled(item.url == nil)
			}
		}
		.cardStyle()
	}

	private var disclaimerCard: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("SORUMLULUK REDDİ")
				.font(.system(size: 14, weight: .heavy))
				.tracking(2.2)
				.foregroundStyle(Color.appMuted)

			Text("Bu uygulama bilgilendirme amaçlıdır. Çıkan sonuçlar; mevzuat, işlem türü ve istisnalara göre değişebilir. Kesin/bağlayıcı işlem yapmadan önce resmi kaynaklardan teyit ediniz.")
				.font(.system(size: 14, weight: .semibold))
				.foregroundStyle(Color.appMuted)
		}
		.cardStyle()
	}
}

struct CalculationPolicyView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			CalculationPolicyView()
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

