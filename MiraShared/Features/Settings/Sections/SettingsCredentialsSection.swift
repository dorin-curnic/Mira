import SwiftUI

struct SettingsCredentialsSection: View {
	@Environment(\.miraLanguage) private var language

	let credentials: WiFiCredentials?
	let isPasswordRevealed: Bool

	let onAddCredentials: () -> Void
	let onRevealPassword: () -> Void
	let onCopyCredential: (CredentialField) -> Void
	let onEditCredentials: () -> Void

	var body: some View {
		MiraCardSection(title: MiraText.credentialsTitle.localized(language)) {
			content
		}
	}

	@ViewBuilder
	private var content: some View {
		if let credentials {
			CredentialsSectionView(
				credentials: credentials,
				isPasswordRevealed: isPasswordRevealed,
				onRevealPassword: onRevealPassword,
				onCopy: onCopyCredential,
				onEdit: onEditCredentials
			)
		} else {
			EmptyCredentialsView(
				onAddCredentials: onAddCredentials
			)
		}
	}
}

private struct EmptyCredentialsView: View {
	@Environment(\.miraLanguage) private var language

	let onAddCredentials: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
			HStack(alignment: .top, spacing: MiraTheme.Spacing.md) {
				Image(systemName: "person.badge.key")
					.font(MiraTheme.Typography.cardTitle)
					.fontWeight(MiraTheme.Typography.cardTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					Text(MiraText.credentialsNoTitle.localized(language))
						.font(MiraTheme.Typography.rowTitle)
						.fontWeight(MiraTheme.Typography.rowTitleWeight)
						.foregroundStyle(MiraTheme.ColorToken.foreground)

					Text(MiraText.credentialsNoSubtitle.localized(language))
						.font(MiraTheme.Typography.rowSubtitle)
						.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}
			}

			Button {
				onAddCredentials()
			} label: {
				HStack {
					Spacer()

					Text(MiraText.credentialsAddButton.localized(language))
						.font(MiraTheme.Typography.button)
						.fontWeight(MiraTheme.Typography.buttonWeight)

					Spacer()
				}
				.frame(height: 24)
			}
			.buttonStyle(.borderedProminent)
			.tint(MiraTheme.ColorToken.primary)
		}
	}
}
