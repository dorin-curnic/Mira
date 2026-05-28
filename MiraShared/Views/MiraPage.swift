import SwiftUI

enum MiraPage: String, CaseIterable, Identifiable {
	case dashboard = "Dashboard"
	case credentials = "Credentials"
	case usage = "Usage"

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .dashboard:
			return "wifi"
		case .credentials:
			return "key"
		case .usage:
			return "chart.line.uptrend.xyaxis"
		}
	}
}
