import SwiftUI

struct SettingsActionRow: View {
	let title: String
	let subtitle: String
	let icon: String
	let trailingIcon: String

	init(
		title: String,
		subtitle: String,
		icon: String,
		trailingIcon: String = "arrow.up.right"
	) {
		self.title = title
		self.subtitle = subtitle
		self.icon = icon
		self.trailingIcon = trailingIcon
	}

	var body: some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			Image(systemName: icon)
				.font(MiraTheme.Typography.rowIcon)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				.frame(width: 24)

			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
				Text(title)
					.font(MiraTheme.Typography.rowTitle)
					.fontWeight(MiraTheme.Typography.rowTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)

				Text(subtitle)
					.font(MiraTheme.Typography.rowSubtitle)
					.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}

			Spacer()

			Image(systemName: trailingIcon)
				.font(MiraTheme.Typography.rowIcon)
				.fontWeight(MiraTheme.Typography.badgeWeight)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				.frame(width: 24)
		}
		.padding(.vertical, MiraTheme.Spacing.md)
		.contentShape(Rectangle())
	}
}
