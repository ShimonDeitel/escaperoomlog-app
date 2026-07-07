import SwiftUI

/// Unique palette for Escape Room Log.
enum EscaperoomlogTheme {
    static let background = Color(hex: "#0E1F1B")
    static let accent = Color(hex: "#1F5C4F")
    static let accentBright = Color(hex: "#3FBF9F")
    static let cardBackground = Color.white
    static let ink = Color.black.opacity(0.85)
    static let secondaryInk = Color.black.opacity(0.55)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
