import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SettingsView: View {
	@Environment(\.miraLanguage) private var language
	@Environment(\.scenePhase) private var scenePhase

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
	@State private var isPortalCopyButtonVisible = false

	var body: some View {
		MiraPageContainer(maxWidth: MiraTheme.Layout.pageMaxWidth) {
			pageHeader
			connectionSection
			credentialsSection
			supportSection
			aboutSection
		}
		.onChange(of: scenePhase) { _, newPhase in
			if newPhase != .active {
				hideSensitiveData()
			}
		}
		.sheet(isPresented: $isShowingCredentialsSheet) {
			EditCredentialsSheet(
				mode: credentialsSheetMode,
				initialCredentials: credentials,
				onSave: { newCredentials in
					credentials = newCredentials
					hideSensitiveData()
				},
				onDelete: deleteCredentials
			)
		}
		.sheet(isPresented: $isShowingReportForm) {
			ReportProblemSheet()
		}
	}

	private var pageHeader: some View {
		MiraPageHeader("Settings")
	}

	private var connectionSection: some View {
		MiraCardSection(title: "Connection") {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
				Toggle(isOn: $allowsAutoReconnect) {
					VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
						Text("Auto-reconnect")
							.font(MiraTheme.Typography.rowTitle)
							.fontWeight(MiraTheme.Typography.rowTitleWeight)
							.foregroundStyle(MiraTheme.ColorToken.foreground)

						Text("Allow Mira to reconnect to university Wi-Fi when needed.")
							.font(MiraTheme.Typography.rowSubtitle)
							.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
					}
				}

				Divider()

				Button {
					togglePortalCopyButton()
				} label: {
					HStack {
						Text(MiraText.portal.localized(language))
							.font(MiraTheme.Typography.rowTitle)
							.fontWeight(MiraTheme.Typography.rowTitleWeight)
							.foregroundStyle(MiraTheme.ColorToken.foreground)
							.fixedSize(horizontal: true, vertical: false)

						Spacer(minLength: MiraTheme.Spacing.md)

						Text(portal)
							.font(MiraTheme.Typography.rowSubtitle)
							.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
							.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
							.multilineTextAlignment(.trailing)
							.lineLimit(1)
							.truncationMode(.middle)
					}
					.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
				.anchorPreference(key: PortalRowBoundsKey.self, value: .bounds) {
					$0
				}
				.overlayPreferenceValue(PortalRowBoundsKey.self) { anchor in
					GeometryReader { geometry in
						if let anchor, isPortalCopyButtonVisible {
							floatingPortalCopyButton
								.fixedSize()
								.position(
									x: geometry.size.width * 0.68,
									y: geometry[anchor].minY - 18
								)
								.transition(
									.asymmetric(
										insertion: .scale(scale: 0.92).combined(with: .opacity),
										removal: .opacity
									)
								)
								.zIndex(10)
						}
					}
					.animation(
						.spring(response: 0.22, dampingFraction: 0.68),
						value: isPortalCopyButtonVisible
					)
				}
			}
		}
	}

	@ViewBuilder
	private var credentialsSection: some View {
		if let credentials {
			MiraCardSection(title: "Credentials") {
				CredentialsSectionView(
					credentials: credentials,
					isPasswordRevealed: isPasswordRevealed,
					onRevealPassword: {
						Task {
							await revealPassword()
						}
					},
					onCopy: { field in
						Task {
							await copyCredential(field)
						}
					},
					onEdit: {
						openEditCredentials()
					}
				)

				if let revealErrorMessage {
					Text(revealErrorMessage)
						.font(MiraTheme.Typography.rowSubtitle)
						.foregroundStyle(MiraTheme.ColorToken.destructive)
						.padding(.top, MiraTheme.Spacing.sm)
				}
			}
		} else {
			MiraCardSection(title: "Credentials") {
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
			guard isPasswordRevealed else {
				await revealPassword()
				return
			}

			ClipboardService.copy(credentials.password)
			revealErrorMessage = nil
		}
	}

	private var emptyCredentialsView: some View {
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
				openAddCredentials()
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

	private var supportSection: some View {
		MiraCardSection(title: "Support") {
			VStack(spacing: 0) {
				Button {
					isShowingReportForm = true
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
					openURL("https://github.com/dorin-curnic/Mira")
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

	private var aboutSection: some View {
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

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
	}

	private func openAddCredentials() {
		credentialsSheetMode = .add
		hideSensitiveData()
		isShowingCredentialsSheet = true
	}

	private func openEditCredentials() {
		credentialsSheetMode = .edit
		hideSensitiveData()
		isShowingCredentialsSheet = true
	}

	private func deleteCredentials() {
		credentials = nil
		hideSensitiveData()
	}

	private func hideSensitiveData() {
		isPasswordRevealed = false
		isPortalCopyButtonVisible = false
		revealErrorMessage = nil
	}

	private struct PortalRowBoundsKey: PreferenceKey {
		static var defaultValue: Anchor<CGRect>?

		static func reduce(
			value: inout Anchor<CGRect>?,
			nextValue: () -> Anchor<CGRect>?
		) {
			value = nextValue() ?? value
		}
	}

	private var floatingPortalCopyButton: some View {
		Button {
			ClipboardService.copy(portal)
			isPortalCopyButtonVisible = false
		} label: {
			Text(MiraText.copyPortal.localized(language))
				.font(MiraTheme.Typography.button)
				.fontWeight(MiraTheme.Typography.buttonWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.padding(.horizontal, 24)
				.padding(.vertical, 12)
				.frame(minHeight: 44)
		}
		.buttonStyle(.miraGlassCopy)
	}

	private func togglePortalCopyButton() {
		isPortalCopyButtonVisible.toggle()
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
