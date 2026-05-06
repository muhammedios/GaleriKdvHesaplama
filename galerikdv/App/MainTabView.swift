import SwiftUI

struct MainTabView: View {
	@EnvironmentObject private var appState: AppState

	var body: some View {
		TabView(selection: $appState.selectedTab) {
			HomeView()
				.tag(AppState.Tab.home)
				.tabItem {
					Label("Hesaplama", systemImage: "plus.forwardslash.minus")
				}
				.environment(\.symbolVariants, .fill)

			MyCarsView()
				.tag(AppState.Tab.cars)
				.tabItem {
					Label("Araçlarım", systemImage: "car")
				}
				.environment(\.symbolVariants, .fill)

			ProfileView()
				.tag(AppState.Tab.profile)
				.tabItem {
					Label("Profil", systemImage: "person.crop.circle")
				}
				.environment(\.symbolVariants, .fill)
		}
		.tint(Color.appGreen)
	}
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
		MainTabView()
			.environmentObject(AppState())
			.environmentObject(CarStore())
    }
}
