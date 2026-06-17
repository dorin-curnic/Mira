import SwiftUI

struct SettingsCredentialsSection: View {
	let credentials: WiFiCredentials?
	let isPasswordRevealed: Bool
	let revealErrorMessage: String?
	let onAddCredentials: () -> Void
	let onRevealPassword: () -> Void
	let onCopyCredential: (CredentialField) -> Void
	let onEditCredentials: () -> Void

	var body: some View {
		MiraCardSection(title: "Credentials") {
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

			if let revealErrorMessage {
				Text(revealErrorMessage)
					.font(MiraTheme.Typography.rowSubtitle)
					.foregroundStyle(MiraTheme.ColorToken.destructive)
					.padding(.top, MiraTheme.Spacing.sm)
			}
		} else {
			EmptyCredentialsView(
				onAddCredentials: onAddCredentials
			)
		}
	}
}

private struct EmptyCredentialsView: View {
	let onAddCredentials: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
			HStack(alignment: .top, spacing: MiraTheme.Spacing.md) {
				Image(systemName: "person.badge.key")
					.font(MiraTheme.Typography.cardTitle)
					.fontWeight(MiraTheme.Typography.cardTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					Text("There are no credentials yet.")
						.font(MiraTheme.Typography.rowTitle)
						.fontWeight(MiraTheme.Typography.rowTitleWeight)
						.foregroundStyle(MiraTheme.ColorToken.foreground)

					Text("Add your university username and password to use Mira connection features.")
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

					Text("Add Credentials")
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
