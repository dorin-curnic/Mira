import SwiftUI

enum MiraPage: String, CaseIterable, Identifiable {
	case dashboard = "Dashboard"
	case credentials = "Credentials"
	case network = "Network"

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .dashboard:
			return "wifi"
		case .credentials:
			return "key"
		case .network:
			return "chart.line.uptrend.xyaxis"
		}
	}
}
