import SwiftUI

struct SettingsConnectionSection: View {
	@Environment(\.miraLanguage) private var language

	@Binding var allowsAutoReconnect: Bool
	@Binding var isPortalCopyButtonVisible: Bool

	let portal: String

	var body: some View {
		MiraCardSection(title: "Connection") {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
				SettingsToggleRow(
					title: "Auto-reconnect",
					subtitle: "Allow Mira to reconnect to university Wi-Fi when needed.",
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
