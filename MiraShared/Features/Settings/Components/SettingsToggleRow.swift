import SwiftUI

struct SettingsToggleRow: View {
	let title: String
	let subtitle: String

	@Binding var isOn: Bool

	var body: some View {
		Toggle(isOn: $isOn) {
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
		}
	}
}
