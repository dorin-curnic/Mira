import SwiftUI

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
