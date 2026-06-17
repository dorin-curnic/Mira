import SwiftUI

struct MiraPageHeader: View {
	let title: String
	let subtitle: String?

	init(
		_ title: String,
		subtitle: String? = nil
	) {
		self.title = title
		self.subtitle = subtitle
	}

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text(title)
				.font(MiraTheme.Typography.pageTitle)
				.fontWeight(MiraTheme.Typography.pageTitleWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			if let subtitle {
				Text(subtitle)
					.font(MiraTheme.Typography.pageSubtitle)
					.fontWeight(MiraTheme.Typography.pageSubtitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
	}
}
