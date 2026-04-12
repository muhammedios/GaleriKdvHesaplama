import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.96)
                    .ignoresSafeArea()

                RadialGradient(
                    colors: [Color.appAmbientMint.opacity(0.30), .clear],
                    center: UnitPoint(x: 0.50, y: 0.16),
                    startRadius: 20,
                    endRadius: geo.size.width * 0.85
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [Color.appAmbientMint.opacity(0.34), .clear],
                    center: UnitPoint(x: 0.50, y: 0.86),
                    startRadius: 20,
                    endRadius: geo.size.width * 0.90
                )
                .ignoresSafeArea()

                VStack {
                    Spacer(minLength: geo.size.height * 0.29)

                    iconCard

                    Text("Galeri KDV Hesaplama")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.appTitle)
                        .shadow(color: .black.opacity(0.08), radius: 1, y: 2)
                        .padding(.top, 26)

                    Text("OTOMOTİV FİNANS ÇÖZÜMÜ")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(5.2)
                        .foregroundStyle(Color.appGreen)
                        .padding(.top, 5)

                    Spacer()
                }
                .padding(.horizontal, 24)

                VStack(spacing: 0) {
                    HStack(spacing: 11) {
                        Circle().fill(Color.appGreenSoft.opacity(0.34)).frame(width: 10, height: 10)
                        Circle().fill(Color.appGreenSoft.opacity(0.44)).frame(width: 10, height: 10)
                        Circle().fill(Color.appGreen.opacity(0.78)).frame(width: 10, height: 10)
                    }

                    Text("Esnaflar İçin Tasarlandı")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTitle.opacity(0.82))
                        .padding(.top, 18)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 8)

            }
        }
    }

    private var iconCard: some View {
        ZStack {
            Image("splashicon")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.appGreenDark.opacity(0.08), radius: 20, y: 10)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
