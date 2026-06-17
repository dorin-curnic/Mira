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

			SettingsConnectionSection(
				allowsAutoReconnect: $allowsAutoReconnect,
				isPortalCopyButtonVisible: $isPortalCopyButtonVisible,
				portal: portal
			)

			SettingsCredentialsSection(
				credentials: credentials,
				isPasswordRevealed: isPasswordRevealed,
				revealErrorMessage: revealErrorMessage,
				onAddCredentials: openAddCredentials,
				onRevealPassword: {
					Task {
						await revealPassword()
					}
				},
				onCopyCredential: { field in
					Task {
						await copyCredential(field)
					}
				},
				onEditCredentials: openEditCredentials
			)

			SettingsSupportSection(
				onShowReportForm: {
					isShowingReportForm = true
				},
				onOpenGitHubRepository: {
					openURL("https://github.com/dorin-curnic/Mira")
				}
			)

			SettingsAboutSection(appVersion: appVersion)
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

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
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
