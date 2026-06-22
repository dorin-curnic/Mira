import SwiftUI

enum MiraPage: String, CaseIterable, Identifiable {
	case dashboard
	case network
	case settings

	var id: Self { self }

	var titleText: MiraText {
		switch self {
		case .dashboard:
			return .navigationDashboard
		case .network:
			return .navigationNetwork
		case .settings:
			return .navigationSettings
		}
	}

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
