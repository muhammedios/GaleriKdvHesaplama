//
//  galerikdvApp.swift
//  galerikdv
//
//  Created by Muhammed Yılmaz on 12.04.2026.
//

import SwiftUI

@main
struct galerikdvApp: App {
	@StateObject private var store = CarStore()
	@StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
				.environmentObject(store)
				.environmentObject(appState)
        }
    }
}
