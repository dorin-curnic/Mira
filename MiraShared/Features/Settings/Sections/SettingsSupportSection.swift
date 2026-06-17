import SwiftUI

struct SettingsSupportSection: View {
	let onShowReportForm: () -> Void
	let onOpenGitHubRepository: () -> Void

	var body: some View {
		MiraCardSection(title: "Support") {
			VStack(spacing: 0) {
				Button {
					onShowReportForm()
				} label: {
					SettingsActionRow(
						title: "Report Form",
						subtitle: "Report a bug or suggest an improvement.",
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
						title: "GitHub Repository",
						subtitle: "Open the Mira source code.",
						icon: "chevron.left.forwardslash.chevron.right"
					)
				}
				.buttonStyle(.plain)
			}
		}
	}
}
