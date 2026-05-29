import SwiftUI

enum MiraThemeMode: String, CaseIterable, Identifiable {
	case system = "System"
	case light = "Light"
	case dark = "Dark"

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .system:
			return "circle.lefthalf.filled"
		case .light:
			return "sun.max"
		case .dark:
			return "moon"
		}
	}

	var colorScheme: ColorScheme? {
		switch self {
		case .system:
			return nil
		case .light:
			return .light
		case .dark:
			return .dark
		}
	}
}
