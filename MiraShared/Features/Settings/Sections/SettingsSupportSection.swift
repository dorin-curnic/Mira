import SwiftUI

struct SettingsSupportSection: View {
	@Environment(\.miraLanguage) private var language
	let onShowReportForm: () -> Void
	let onOpenGitHubRepository: () -> Void

	var body: some View {
		MiraCardSection(title: MiraText.settingsSupportTitle.localized(language)) {
			VStack(spacing: 0) {
				Button {
					onShowReportForm()
				} label: {
					SettingsActionRow(
						title: MiraText.settingsReportFormTitle.localized(language),
						subtitle: MiraText.settingsReportFormSubtitle.localized(language),
						icon: "exclamationmark.bubble",
						trailingIcon: "pencil.and.list.clipboard"
					)
				}
				.buttonStyle(.plain)

				Divider()

				Button {
					onOpenGitHubRepository()
				} label: {
					SettingsActionRow(
						title: MiraText.settingsGitHubRepositoryTitle.localized(language),
						subtitle: MiraText.settingsGitHubRepositorySubtitle.localized(language),
						icon: "chevron.left.forwardslash.chevron.right"
					)
				}
				.buttonStyle(.plain)
			}
		}
	}
}
