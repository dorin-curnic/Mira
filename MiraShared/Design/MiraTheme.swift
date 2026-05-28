import SwiftUI

enum MiraTheme {
	enum Radius {
		static let sm: CGFloat = 6
		static let md: CGFloat = 10
		static let lg: CGFloat = 14
		static let xl: CGFloat = 18
		static let xxl: CGFloat = 24
	}

	enum Spacing {
		static let xs: CGFloat = 4
		static let sm: CGFloat = 8
		static let md: CGFloat = 12
		static let lg: CGFloat = 16
		static let xl: CGFloat = 24
		static let xxl: CGFloat = 32
	}

	enum ColorToken {
		static let background = Color(hex: 0xffffff)
		static let foreground = Color(hex: 0x09090b)

		static let card = Color(hex: 0xffffff)
		static let cardForeground = Color(hex: 0x09090b)

		static let primary = Color(hex: 0xc6005c)
		static let primaryForeground = Color(hex: 0xfdf2f8)

		static let secondary = Color(hex: 0xf4f4f5)
		static let secondaryForeground = Color(hex: 0x18181b)

		static let muted = Color(hex: 0xf4f4f5)
		static let mutedForeground = Color(hex: 0x71717b)

		static let accent = Color(hex: 0xf4f4f5)
		static let accentForeground = Color(hex: 0x18181b)

		static let destructive = Color(hex: 0xdc2626)
		static let border = Color(hex: 0xe4e4e7)
		static let input = Color(hex: 0xe4e4e7)
		static let ring = Color(hex: 0xa1a1aa)

		static let chart1 = Color(hex: 0xffd230)
		static let chart2 = Color(hex: 0xfe9a00)
		static let chart3 = Color(hex: 0xe17100)
		static let chart4 = Color(hex: 0xbb4d00)
		static let chart5 = Color(hex: 0x973c00)

		static let darkBackground = Color(hex: 0x09090b)
		static let darkForeground = Color(hex: 0xfafafa)
		static let darkCard = Color(hex: 0x18181b)
		static let darkPrimary = Color(hex: 0xa3004c)
		static let darkSecondary = Color(hex: 0x27272a)
		static let darkBorder = Color.white.opacity(0.10)
	}

	enum Status {
		static let connectedForeground = Color(red: 94 / 255, green: 194 / 255, blue: 105 / 255)
		static let connectedBackground = Color(red: 226 / 255, green: 251 / 255, blue: 232 / 255)
		static let connectedBorder = Color(red: 48 / 255, green: 99 / 255, blue: 57 / 255)

		static let pendingForeground = Color(red: 233 / 255, green: 162 / 255, blue: 59 / 255)
		static let pendingBackground = Color(red: 252 / 255, green: 243 / 255, blue: 204 / 255)
		static let pendingBorder = Color(red: 136 / 255, green: 69 / 255, blue: 29 / 255)

		static let rejectedForeground = Color(red: 221 / 255, green: 82 / 255, blue: 76 / 255)
		static let rejectedBackground = Color(red: 249 / 255, green: 227 / 255, blue: 226 / 255)
		static let rejectedBorder = Color(red: 140 / 255, green: 40 / 255, blue: 34 / 255)

		static let disconnectedForeground = Color(red: 108 / 255, green: 114 / 255, blue: 127 / 255)
		static let disconnectedBackground = Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255)
		static let disconnectedBorder = Color(red: 57 / 255, green: 65 / 255, blue: 80 / 255)
	}
}

extension Color {
	init(hex: UInt, alpha: Double = 1.0) {
		self.init(
			.sRGB,
			red: Double((hex >> 16) & 0xff) / 255,
			green: Double((hex >> 8) & 0xff) / 255,
			blue: Double(hex & 0xff) / 255,
			opacity: alpha
		)
	}
}
