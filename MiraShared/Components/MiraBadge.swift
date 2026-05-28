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
}

struct MiraBadge: View {
	let status: WiFiConnectionStatus

	var body: some View {
		HStack(spacing: 6) {
			Circle()
				.fill(status.foregroundColor)
				.frame(width: 7, height: 7)

			Text(status.rawValue)
				.font(.caption)
				.fontWeight(.medium)
		}
		.foregroundStyle(status.foregroundColor)
		.padding(.horizontal, MiraTheme.Spacing.md)
		.padding(.vertical, MiraTheme.Spacing.xs)
		.background(status.backgroundColor)
		.clipShape(Capsule())
	}
}
