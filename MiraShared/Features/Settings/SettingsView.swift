import SwiftUI

#if os(iOS)
	import UIKit
#elseif os(macOS)
	import AppKit
#endif

struct SettingsView: View {
	@Environment(\.miraLanguage) private var language
	@Environment(\.scenePhase) private var scenePhase
	@Environment(MiraSonnerCenter.self) private var sonner

	@State private var credentials: WiFiCredentials?
	@State private var isShowingCredentialsSheet = false
	@State private var credentialsSheetMode: EditCredentialsSheet.Mode = .add
	@State private var isPasswordRevealed = false
	@State private var isShowingReportForm = false

	private let authService = AuthService()

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
				onAddCredentials: openAddCredentials,
				onRevealPassword: {
					Task { await revealPassword() }
				},
				onCopyCredential: copyCredential,
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
				onSave: saveCredentials,
				onDelete: deleteCredentials
			)
		}
		.sheet(isPresented: $isShowingReportForm) {
			ReportProblemSheet(
				onSubmit: handleReportSubmit
			)
		}
	}

	private var pageHeader: some View {
		MiraPageHeader(MiraText.settingsTitle.localized(language))
	}

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
	}

	private func copyPortal() {
		ClipboardService.copy(portal)
		isPortalCopyButtonVisible = false
	}

	private func copyCredential(_ field: CredentialField) {
		guard let credentials else {
			return
		}

		switch field {
		case .username:
			ClipboardService.copy(credentials.username)

		case .password:
			ClipboardService.copy(credentials.password)
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

	private func saveCredentials(_ newCredentials: WiFiCredentials) {
		let isAddingCredentials = credentials == nil

		credentials = newCredentials
		hideSensitiveData()

		if isAddingCredentials {
			sonner.show(.success(MiraText.feedbackCredentialsAdded.localized(language)))
		} else {
			sonner.show(.success(MiraText.feedbackCredentialsUpdated.localized(language)))
		}
	}

	private func deleteCredentials() {
		credentials = nil
		hideSensitiveData()

		sonner.show(.success(MiraText.feedbackCredentialsDeleted.localized(language)))
	}

	private func handleReportSubmit(_ result: Result<Void, Error>) {
		switch result {
		case .success:
			sonner.show(.success(MiraText.feedbackReportSent.localized(language)))

		case .failure:
			sonner.show(.error(MiraText.feedbackReportSendFailed.localized(language)))
		}
	}

	private func hideSensitiveData() {
		isPasswordRevealed = false
		isPortalCopyButtonVisible = false
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

	@MainActor
	private func revealPassword() async {
		guard requiresAuthenticationBeforeReveal else {
			isPasswordRevealed.toggle()
			return
		}

		do {
			try await authService.authenticate(
				reason: MiraText.credentialsRevealAuthenticationReason.localized(language),
				language: language
			)

			isPasswordRevealed = true
		} catch {
			isPasswordRevealed = false
			sonner.show(.error(MiraText.feedbackPasswordRevealFailed.localized(language)))
		}
	}
}

#Preview {
	MiraSonnerHost {
		SettingsView()
	}
}
