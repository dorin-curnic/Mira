import SwiftUI

enum MiraPage: String, CaseIterable, Identifiable {
	case dashboard = "Dashboard"
	case network = "Network"
	case settings = "Settings"

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .dashboard:
			return "wifi"
		case .network:
			return "chart.line.uptrend.xyaxis"
		case .settings:
			return "gearshape"
		}
	}
}
