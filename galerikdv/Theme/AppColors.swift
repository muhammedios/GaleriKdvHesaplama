import SwiftUI

extension Color {
    // Base surfaces (DESIGN.md)
    static let appScreen = Color(red: 0.973, green: 0.976, blue: 0.980) // #f8f9fa
    static let appSurfaceLow = Color(red: 0.953, green: 0.957, blue: 0.961) // #f3f4f5
    static let appSurfaceLowest = Color(red: 1.0, green: 1.0, blue: 1.0) // #ffffff

    // Brand greens
    static let appGreen = Color(red: 0.0, green: 0.427, blue: 0.216) // #006d37
    static let appGreenSoft = Color(red: 0.180, green: 0.800, blue: 0.443) // #2ecc71
    static let appGreenDark = Color(red: 0.0, green: 0.325, blue: 0.169)

    // Typography and utility
    static let appTitle = Color(red: 0.098, green: 0.110, blue: 0.114) // #191c1d
    static let appMuted = Color(red: 0.424, green: 0.482, blue: 0.427) // #6c7b6d
    static let appInfo = Color(red: 0.388, green: 0.451, blue: 0.396)
    static let appModeCard = appSurfaceLow
    static let appModeText = Color(red: 0.157, green: 0.196, blue: 0.165)
    static let appSelectedText = appSurfaceLowest
    static let appInputText = Color(red: 0.161, green: 0.208, blue: 0.173)
    static let appResultLabel = Color(red: 0.290, green: 0.882, blue: 0.514)
    static let cardBackground = appSurfaceLow

    // Accent and ambient
    static let appOutlineVariant = Color(red: 0.733, green: 0.796, blue: 0.733) // #bbcbbb
    static let appAmbientMint = Color(red: 0.851, green: 0.941, blue: 0.898)
}
