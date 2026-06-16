import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

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
		static let background = Color.dynamic(
			light: Color(hex: 0xFFFFFF),
			dark: Color(hex: 0x09090B)
		)

		static let foreground = Color.dynamic(
			light: Color(hex: 0x09090B),
			dark: Color(hex: 0xFAFAFA)
		)

		static let card = Color.dynamic(
			light: Color(hex: 0xFFFFFF),
			dark: Color(hex: 0x18181B)
		)

		static let cardForeground = Color.dynamic(
			light: Color(hex: 0x09090B),
			dark: Color(hex: 0xFAFAFA)
		)

		static let popover = Color.dynamic(
			light: Color(hex: 0xFFFFFF),
			dark: Color(hex: 0x18181B)
		)

		static let popoverForeground = Color.dynamic(
			light: Color(hex: 0x09090B),
			dark: Color(hex: 0xFAFAFA)
		)

		static let primary = Color.dynamic(
			light: Color(hex: 0xC6005C),
			dark: Color(hex: 0xA3004C)
		)

		static let primaryForeground = Color.dynamic(
			light: Color(hex: 0xFDF2F8),
			dark: Color(hex: 0xFDF2F8)
		)

		static let secondary = Color.dynamic(
			light: Color(hex: 0xF4F4F5),
			dark: Color(hex: 0x27272A)
		)

		static let secondaryForeground = Color.dynamic(
			light: Color(hex: 0x18181B),
			dark: Color(hex: 0xFAFAFA)
		)

		static let muted = Color.dynamic(
			light: Color(hex: 0xF4F4F5),
			dark: Color(hex: 0x27272A)
		)

		static let mutedForeground = Color.dynamic(
			light: Color(hex: 0x71717B),
			dark: Color(hex: 0x9F9FA9)
		)

		static let accent = Color.dynamic(
			light: Color(hex: 0xF4F4F5),
			dark: Color(hex: 0x27272A)
		)

		static let accentForeground = Color.dynamic(
			light: Color(hex: 0x18181B),
			dark: Color(hex: 0xFAFAFA)
		)

		static let destructive = Color.dynamic(
			light: Color(hex: 0xE7000B),
			dark: Color(hex: 0xFF6467)
		)

		static let border = Color.dynamic(
			light: Color(hex: 0xE4E4E7),
			dark: Color.white.opacity(0.10)
		)

		static let input = Color.dynamic(
			light: Color(hex: 0xE4E4E7),
			dark: Color.white.opacity(0.15)
		)

		static let ring = Color.dynamic(
			light: Color(hex: 0x9F9FA9),
			dark: Color(hex: 0x71717B)
		)

		static let chart1 = Color(hex: 0xFFD230)
		static let chart2 = Color(hex: 0xFE9A00)
		static let chart3 = Color(hex: 0xE17100)
		static let chart4 = Color(hex: 0xBB4D00)
		static let chart5 = Color(hex: 0x973C00)

		static let sidebar = Color.dynamic(
			light: Color(hex: 0xFAFAFA),
			dark: Color(hex: 0x18181B)
		)

		static let sidebarForeground = Color.dynamic(
			light: Color(hex: 0x09090B),
			dark: Color(hex: 0xFAFAFA)
		)

		static let sidebarPrimary = Color.dynamic(
			light: Color(hex: 0xE60076),
			dark: Color(hex: 0xF6339A)
		)

		static let sidebarPrimaryForeground = Color.dynamic(
			light: Color(hex: 0xFDF2F8),
			dark: Color(hex: 0xFDF2F8)
		)

		static let sidebarAccent = Color.dynamic(
			light: Color(hex: 0xF4F4F5),
			dark: Color(hex: 0x27272A)
		)

		static let sidebarAccentForeground = Color.dynamic(
			light: Color(hex: 0x18181B),
			dark: Color(hex: 0xFAFAFA)
		)

		static let sidebarBorder = Color.dynamic(
			light: Color(hex: 0xE4E4E7),
			dark: Color.white.opacity(0.10)
		)

		static let sidebarRing = Color.dynamic(
			light: Color(hex: 0x9F9FA9),
			dark: Color(hex: 0x71717B)
		)
	}

	enum Status {
		static let connectedForeground = Color.dynamic(
			light: Color(red: 94 / 255, green: 194 / 255, blue: 105 / 255),
			dark: Color(red: 134 / 255, green: 239 / 255, blue: 172 / 255)
		)

		static let connectedBackground = Color.dynamic(
			light: Color(red: 226 / 255, green: 251 / 255, blue: 232 / 255),
			dark: Color(red: 20 / 255, green: 83 / 255, blue: 45 / 255).opacity(0.35)
		)

		static let connectedBorder = Color.dynamic(
			light: Color(red: 48 / 255, green: 99 / 255, blue: 57 / 255),
			dark: Color(red: 134 / 255, green: 239 / 255, blue: 172 / 255).opacity(0.45)
		)

		static let pendingForeground = Color.dynamic(
			light: Color(red: 233 / 255, green: 162 / 255, blue: 59 / 255),
			dark: Color(red: 251 / 255, green: 191 / 255, blue: 36 / 255)
		)

		static let pendingBackground = Color.dynamic(
			light: Color(red: 252 / 255, green: 243 / 255, blue: 204 / 255),
			dark: Color(red: 113 / 255, green: 63 / 255, blue: 18 / 255).opacity(0.35)
		)

		static let pendingBorder = Color.dynamic(
			light: Color(red: 136 / 255, green: 69 / 255, blue: 29 / 255),
			dark: Color(red: 251 / 255, green: 191 / 255, blue: 36 / 255).opacity(0.45)
		)

		static let rejectedForeground = Color.dynamic(
			light: Color(red: 221 / 255, green: 82 / 255, blue: 76 / 255),
			dark: Color(red: 248 / 255, green: 113 / 255, blue: 113 / 255)
		)

		static let rejectedBackground = Color.dynamic(
			light: Color(red: 249 / 255, green: 227 / 255, blue: 226 / 255),
			dark: Color(red: 127 / 255, green: 29 / 255, blue: 29 / 255).opacity(0.35)
		)

		static let rejectedBorder = Color.dynamic(
			light: Color(red: 140 / 255, green: 40 / 255, blue: 34 / 255),
			dark: Color(red: 248 / 255, green: 113 / 255, blue: 113 / 255).opacity(0.45)
		)

		static let disconnectedForeground = Color.dynamic(
			light: Color(red: 108 / 255, green: 114 / 255, blue: 127 / 255),
			dark: Color(red: 156 / 255, green: 163 / 255, blue: 175 / 255)
		)

		static let disconnectedBackground = Color.dynamic(
			light: Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255),
			dark: Color(red: 55 / 255, green: 65 / 255, blue: 81 / 255).opacity(0.35)
		)

		static let disconnectedBorder = Color.dynamic(
			light: Color(red: 57 / 255, green: 65 / 255, blue: 80 / 255),
			dark: Color(red: 156 / 255, green: 163 / 255, blue: 175 / 255).opacity(0.45)
		)
	}

	enum Typography {
		static let appTitle: Font = .title2
		static let appTitleWeight: Font.Weight = .semibold

		static let pageTitle: Font = .largeTitle
		static let pageTitleWeight: Font.Weight = .bold

		static let pageSubtitle: Font = .subheadline
		static let pageSubtitleWeight: Font.Weight = .regular

		static let sectionTitle: Font = .headline
		static let sectionTitleWeight: Font.Weight = .semibold

		static let cardTitle: Font = .title3
		static let cardTitleWeight: Font.Weight = .semibold

		static let cardSubtitle: Font = .subheadline
		static let cardSubtitleWeight: Font.Weight = .regular

		static let rowTitle: Font = .subheadline
		static let rowTitleWeight: Font.Weight = .semibold

		static let rowValue: Font = .subheadline
		static let rowValueWeight: Font.Weight = .medium

		static let rowSubtitle: Font = .caption
		static let rowSubtitleWeight: Font.Weight = .regular

		static let badge: Font = .caption
		static let badgeWeight: Font.Weight = .medium

		static let button: Font = .subheadline
		static let buttonWeight: Font.Weight = .semibold

		static let icon: Font = .subheadline
		static let rowIcon: Font = .subheadline
		static let cardIcon: Font = .title3
		
		static let metricValue: Font = .system(size: 42, weight: .bold, design: .rounded)
		static let metricLabel: Font = .subheadline
		static let metricLabelWeight: Font.Weight = .medium
	}

	enum Layout {
		static let pageMaxWidth: CGFloat = 820
		static let widePageMaxWidth: CGFloat = 980
		static let sheetMaxWidth: CGFloat = 560
		static let reportSheetMaxWidth: CGFloat = 620
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

extension Color {
	static func dynamic(light: Color, dark: Color) -> Color {
#if os(iOS)
		return Color(
			UIColor { traitCollection in
				traitCollection.userInterfaceStyle == .dark
				? UIColor(dark)
				: UIColor(light)
			}
		)
#elseif os(macOS)
		return Color(
			NSColor(name: nil) { appearance in
				let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
				return isDark ? NSColor(dark) : NSColor(light)
			}
		)
#endif
	}
}
