import SwiftUI

struct SettingsConnectionSection: View {
	@Environment(\.miraLanguage) private var language

	@Binding var allowsAutoReconnect: Bool
	@Binding var isPortalCopyButtonVisible: Bool

	let portal: String

	var body: some View {
		MiraCardSection(title: MiraText.settingsConnectionTitle.localized(language)) {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
				SettingsToggleRow(
					title: MiraText.settingsAutoReconnectTitle.localized(language),
					subtitle: MiraText.settingsAutoReconnectSubtitle.localized(language),
					isOn: $allowsAutoReconnect
				)

				Divider()

				SettingsCopyValueRow(
					title: MiraText.portal.localized(language),
					value: portal,
					copyLabel: MiraText.copyPortal.localized(language),
					isCopyButtonVisible: isPortalCopyButtonVisible,
					onToggleCopyButton: togglePortalCopyButton,
					onCopy: copyPortal
				)
			}
		}
	}

	private func togglePortalCopyButton() {
		isPortalCopyButtonVisible.toggle()
	}

	private func copyPortal() {
		ClipboardService.copy(portal)
		isPortalCopyButtonVisible = false
	}
}
