import SwiftUI

struct SettingsAboutSection: View {
	@Environment(\.miraLanguage) private var language
	let appVersion: String

	var body: some View {
		MiraCardSection(title: MiraText.settingsAboutTitle.localized(language)) {
			VStack(spacing: 0) {
				SettingsInfoRow(
					title: MiraText.settingsVersionTitle.localized(language),
					value: appVersion,
					icon: "info.circle"
				)
			}
		}
	}
}
