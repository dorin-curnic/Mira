import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SettingsView: View {
	@Environment(\.miraLanguage) private var language

	@State private var credentials: WiFiCredentials?
	@State private var isShowingCredentialsSheet = false
	@State private var credentialsSheetMode: EditCredentialsSheet.Mode = .add
	@State private var isPasswordRevealed = false
	@State private var isShowingReportForm = false

	private let authService = AuthService()
	@State private var revealErrorMessage: String?

	@State private var allowsAutoReconnect = true
	@State private var requiresAuthenticationBeforeReveal = true

	private let portal = "https://sb.sdn.utm.md:19008/portal"

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
				pageHeader
				connectionSection
				credentialsSection
				supportSection
				aboutSection
			}
			.padding(MiraTheme.Spacing.xl)
			.frame(maxWidth: 820)
			.frame(maxWidth: .infinity)
		}
		.background(MiraTheme.ColorToken.background)
		.contentShape(Rectangle())
		.sheet(isPresented: $isShowingCredentialsSheet) {
			EditCredentialsSheet(
				mode: credentialsSheetMode,
				initialCredentials: credentials,
				onSave: { newCredentials in
					credentials = newCredentials
					isPasswordRevealed = false
					revealErrorMessage = nil
				},
				onDelete: {
					deleteCredentials()
				}
			)
		}
		.sheet(isPresented: $isShowingReportForm) {
			ReportProblemSheet()
		}
	}

	private var pageHeader: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text("Settings")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
		}
	}

	private var connectionSection: some View {
		SettingsSectionView(title: "Connection") {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
				Toggle(isOn: $allowsAutoReconnect) {
					VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
						Text("Auto-reconnect")
							.font(.subheadline)
							.fontWeight(.semibold)
							.foregroundStyle(MiraTheme.ColorToken.foreground)

						Text("Allow Mira to reconnect to university Wi-Fi when needed.")
							.font(.caption)
							.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					}
				}

				Divider()

				Button {
					ClipboardService.copy(portal)
				} label: {
					HStack {
						VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
							Text(MiraText.portal.localized(language))
								.font(.subheadline)
								.fontWeight(.semibold)
								.foregroundStyle(MiraTheme.ColorToken.foreground)

							Text(portal)
								.font(.caption)
								.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
								.lineLimit(1)
								.truncationMode(.middle)
						}

						Spacer()

						Image(systemName: "doc.on.doc")
							.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					}
					.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
			}
		}
	}

	@ViewBuilder
	private var credentialsSection: some View {
		if let credentials {
			SettingsSectionView(
				title: "Credentials",
				trailing: {
					Button {
						openEditCredentials()
					} label: {
						Text("Edit")
							.font(.subheadline)
							.fontWeight(.semibold)
					}
					.buttonStyle(.plain)
					.foregroundStyle(MiraTheme.ColorToken.primary)
				}
			) {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
					SavedCredentialsView(
						credentials: credentials,
						isPasswordRevealed: isPasswordRevealed,
						onPasswordTap: {
							Task {
								await revealPassword()
							}
						},
						onCopy: { field in
							Task {
								await copyCredential(field)
							}
						}
					)

					if let revealErrorMessage {
						Text(revealErrorMessage)
							.font(.caption)
							.foregroundStyle(MiraTheme.ColorToken.destructive)
					}
				}
			}
		} else {
			SettingsSectionView(title: "Credentials") {
				emptyCredentialsView
			}
		}
	}

	private func copyCredential(_ field: CredentialField) async {
		guard let credentials else {
			return
		}

		switch field {
		case .username:
			ClipboardService.copy(credentials.username)

		case .password:
			do {
				if requiresAuthenticationBeforeReveal {
					try await authService.authenticate(
						reason: "Authenticate to copy your saved password."
					)
				}

				ClipboardService.copy(credentials.password)
				revealErrorMessage = nil
			} catch {
				revealErrorMessage = error.localizedDescription
			}

		case .portal:
			break
		}
	}

	private var emptyCredentialsView: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
			HStack(alignment: .top, spacing: MiraTheme.Spacing.md) {
				Image(systemName: "person.badge.key")
					.font(.title3)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					Text("There are no credentials yet.")
						.font(.subheadline)
						.fontWeight(.semibold)
						.foregroundStyle(MiraTheme.ColorToken.foreground)

					Text("Add your university username and password to use Mira connection features.")
						.font(.caption)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}
			}

			Button {
				openAddCredentials()
			} label: {
				HStack {
					Spacer()
					Text("Add Credentials")
						.fontWeight(.semibold)
					Spacer()
				}
				.frame(height: 24)
			}
			.buttonStyle(.borderedProminent)
			.tint(MiraTheme.ColorToken.primary)
		}
	}

	private var supportSection: some View {
		SettingsSectionView(title: "Support") {
			VStack(spacing: 0) {
				Button {
					openURL("https://github.com/dorin-curnic/Mira")
				} label: {
					settingsActionRow(
						title: "GitHub Repository",
						subtitle: "Open the Mira source code.",
						icon: "chevron.left.forwardslash.chevron.right"
					)
				}
				.buttonStyle(.plain)

				Divider()

				Button {
					isShowingReportForm = true
				} label: {
					settingsActionRow(
						title: "Report Form",
						subtitle: "Report a bug or suggest an improvement.",
						icon: "exclamationmark.bubble"
					)
				}
				.buttonStyle(.plain)
			}
		}
	}

	private var aboutSection: some View {
		SettingsSectionView(title: "About") {
			VStack(spacing: 0) {
				settingsInfoRow(
					title: "App Version",
					value: appVersion,
					icon: "info.circle"
				)
			}
		}
	}

	private func settingsInfoRow(
		title: String,
		value: String,
		icon: String
	) -> some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			Image(systemName: icon)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				.frame(width: 24)

			Text(title)
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Spacer()

			Text(value)
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
		.padding(.vertical, MiraTheme.Spacing.md)
	}

	private func settingsActionRow(
		title: String,
		subtitle: String,
		icon: String
	) -> some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			Image(systemName: icon)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				.frame(width: 24)

			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
				Text(title)
					.font(.subheadline)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.foreground)

				Text(subtitle)
					.font(.caption)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}

			Spacer()

			Image(systemName: "arrow.up.right")
				.font(.caption)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
		.padding(.vertical, MiraTheme.Spacing.md)
		.contentShape(Rectangle())
	}

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
	}

	private func openAddCredentials() {
		credentialsSheetMode = .add
		isShowingCredentialsSheet = true
	}

	private func openEditCredentials() {
		credentialsSheetMode = .edit
		isShowingCredentialsSheet = true
	}

	private func deleteCredentials() {
		credentials = nil
		isPasswordRevealed = false
		revealErrorMessage = nil
	}

	private func openURL(_ string: String) {
		guard let url = URL(string: string) else {
			return
		}
	

#if os(iOS)
		UIApplication.shared.open(url)
#elseif os(macOS)
		NSWorkspace.shared.open(url)
#endif
	}

	private func revealPassword() async {
		guard requiresAuthenticationBeforeReveal else {
			isPasswordRevealed.toggle()
			return
		}

		do {
			try await authService.authenticate(
				reason: "Authenticate to reveal your saved password."
			)

			isPasswordRevealed = true
			revealErrorMessage = nil
		} catch {
			revealErrorMessage = error.localizedDescription
		}
	}
}

#Preview {
	SettingsView()
}
