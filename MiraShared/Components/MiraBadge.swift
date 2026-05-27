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

	var borderColor: Color {
		switch self {
		case .connected:
			return MiraTheme.Status.connectedBorder
		case .pending:
			return MiraTheme.Status.pendingBorder
		case .rejected:
			return MiraTheme.Status.rejectedBorder
		case .disconnected:
			return MiraTheme.Status.disconnectedBorder
		}
	}
}

struct MiraBadge: View {
	let status: WiFiConnectionStatus

	var body: some View {
		Text(status.rawValue)
			.font(.caption)
			.fontWeight(.medium)
			.foregroundStyle(status.foregroundColor)
			.padding(.horizontal, MiraTheme.Spacing.md)
			.padding(.vertical, MiraTheme.Spacing.xs)
			.background(status.backgroundColor)
			.clipShape(Capsule())
			.overlay {
				Capsule()
					.stroke(status.borderColor.opacity(0.25), lineWidth: 1)
			}
	}
}
