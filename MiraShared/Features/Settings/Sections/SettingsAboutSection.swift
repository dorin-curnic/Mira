import SwiftUI

struct SettingsAboutSection: View {
	let appVersion: String

	var body: some View {
		MiraCardSection(title: "About") {
			VStack(spacing: 0) {
				SettingsInfoRow(
					title: "Version",
					value: appVersion,
					icon: "info.circle"
				)
			}
		}
	}
}
