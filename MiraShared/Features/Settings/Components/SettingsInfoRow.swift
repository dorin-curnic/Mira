import SwiftUI

struct SettingsInfoRow: View {
	let title: String
	let value: String
	let icon: String

	var body: some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			Image(systemName: icon)
				.font(MiraTheme.Typography.rowIcon)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				.frame(width: 24)

			Text(title)
				.font(MiraTheme.Typography.rowTitle)
				.fontWeight(MiraTheme.Typography.rowTitleWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Spacer()

			Text(value)
				.font(MiraTheme.Typography.rowValue)
				.fontWeight(MiraTheme.Typography.rowValueWeight)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				.lineLimit(1)
				.truncationMode(.middle)
		}
		.padding(.vertical, MiraTheme.Spacing.md)
	}
}
