import SwiftUI

enum WiFiConnectionStatus: String, CaseIterable {
	case connected = "Connected"
	case pending = "Pending"
	case rejected = "Rejected"
	case disconnected = "Disconnected"

	var foregroundColor: Color {
		switch self {
		case .connected:
			return MiraTheme.Status.connectedForeground
		case .pending:
			return MiraTheme.Status.pendingForeground
		case .rejected:
			return MiraTheme.Status.rejectedForeground
		case .disconnected:
			return MiraTheme.Status.disconnectedForeground
		}
	}

	var backgroundColor: Color {
		switch self {
		case .connected:
			return MiraTheme.Status.connectedBackground
		case .pending:
			return MiraTheme.Status.pendingBackground
		case .rejected:
			return MiraTheme.Status.rejectedBackground
		case .disconnected:
			return MiraTheme.Status.disconnectedBackground
		}
	}

	var displayText: MiraText {
		switch self {
		case .connected:
			return .connected
		case .pending:
			return .pending
		case .rejected:
			return .rejected
		case .disconnected:
			return .disconnected
		}
	}
}
