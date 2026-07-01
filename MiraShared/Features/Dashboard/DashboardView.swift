import SwiftUI

struct DashboardView: View {
	@Environment(\.miraLanguage) private var language
	@Environment(MiraSonnerCenter.self) private var sonner

	@State private var connectionStatus: WiFiConnectionStatus = .disconnected
	@State private var isAuthenticating = false
	@State private var userAllowsAutoReconnect = false

	@State private var isSpeedTesting = false
	@State private var speedTestResult: SpeedTestResult?
	@State private var currentSpeedValueText = "0.0"
	@State private var speedTestProgress = 0.0

	private let authService = AuthService()
	private let speedTestService = SpeedTestService()

	var body: some View {
		MiraPageContainer(maxWidth: MiraTheme.Layout.pageMaxWidth) {
			pageHeader
			wifiStatusCard
			connectionActionButton
			speedTestCard
		}
	}

	private var pageHeader: some View {
		MiraPageHeader(
			MiraText.dashboardTitle.localized(language),
			subtitle: MiraText.dashboardSubtitle.localized(language)
		)
	}

	private var connectionActionButton: some View {
		Button {
			if connectionStatus == .connected {
				disconnect()
			} else {
				Task {
					await connect()
				}
			}
		} label: {
			HStack(spacing: MiraTheme.Spacing.sm) {
				Spacer()

				if isAuthenticating {
					ProgressView()
						.tint(MiraTheme.ColorToken.primaryForeground)
				} else {
					Text(connectionActionTitle)
						.font(MiraTheme.Typography.button)
						.fontWeight(MiraTheme.Typography.buttonWeight)
				}

				Spacer()
			}
			.frame(height: 24)
		}
		.buttonStyle(.borderedProminent)
		.tint(connectionActionTint)
		.disabled(isAuthenticating)
	}

	private var wifiStatusCard: some View {
		MiraCard {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
				HStack(alignment: .top, spacing: MiraTheme.Spacing.md) {
					Text(MiraText.wifiName.localized(language))
						.font(MiraTheme.Typography.cardTitle)
						.fontWeight(MiraTheme.Typography.cardTitleWeight)
						.foregroundStyle(MiraTheme.ColorToken.foreground)

					Spacer()

					MiraBadge(status: connectionStatus)
				}

				Spacer()

				Text(MiraText.wifiDescription.localized(language))
					.font(MiraTheme.Typography.cardSubtitle)
					.fontWeight(MiraTheme.Typography.cardSubtitleWeight)
			}
		}
	}

	private var speedTestCard: some View {
		SpeedTestCard(
			displayedSpeedValueText: displayedSpeedValueText,
			progress: speedTestProgress,
			isTesting: isSpeedTesting,
			isFinished: speedTestResult != nil,
			onStartTest: {
				Task {
					await runSpeedTest()
				}
			}
		)
	}

	private var connectionActionTitle: String {
		if connectionStatus == .connected {
			return MiraText.disconnect.localized(language)
		} else {
			return MiraText.connect.localized(language)
		}
	}

	private var connectionActionTint: Color {
		connectionStatus == .connected
			? MiraTheme.ColorToken.destructive
			: MiraTheme.ColorToken.primary
	}

	private var displayedSpeedValueText: String {
		if isSpeedTesting {
			return currentSpeedValueText
		}

		return speedTestResult?.speedValueText ?? "0.0"
	}

	private func connect() async {
		isAuthenticating = true
		connectionStatus = .pending

		defer {
			isAuthenticating = false
		}

		do {
			try await authService.authenticate(
				reason: MiraText.authenticateReason.localized(language),
				language: language
			)

			userAllowsAutoReconnect = true
			connectionStatus = .connected

			sonner.show(
				.connected(
					MiraText.dashboardFeedbackConnectedTitle.localized(language),
					description: MiraText.dashboardFeedbackConnectedDescription.localized(language)
				)
			)
		} catch let error as AuthError {
			userAllowsAutoReconnect = false
			connectionStatus = .rejected

			showAuthenticationFeedback(for: error)
		} catch {
			userAllowsAutoReconnect = false
			connectionStatus = .rejected

			sonner.show(
				.error(
					MiraText.dashboardFeedbackAuthFailedTitle.localized(language),
					description: error.localizedDescription
				)
			)
		}
	}

	private func disconnect() {
		userAllowsAutoReconnect = false
		connectionStatus = .disconnected

		sonner.show(
			.disconnected(
				MiraText.dashboardFeedbackDisconnectedTitle.localized(language),
				description: MiraText.dashboardFeedbackDisconnectedDescription.localized(language)
			)
		)
	}

	private func runSpeedTest() async {
		guard !isSpeedTesting else {
			return
		}

		isSpeedTesting = true
		speedTestResult = nil
		currentSpeedValueText = "0.0"
		speedTestProgress = 0

		defer {
			isSpeedTesting = false
		}

		do {
			for try await event in speedTestService.runDownloadTest() {
				switch event {
				case .progress(let progress):
					currentSpeedValueText = progress.speedValueText
					speedTestProgress = progress.progress

				case .completed(let result):
					speedTestResult = result
					currentSpeedValueText = result.speedValueText
					speedTestProgress = 1
				}
			}
		} catch let error as SpeedTestError {
			let message = error.errorDescription(language: language)

			speedTestProgress = 0
			currentSpeedValueText = "0.0"

			sonner.show(
				.error(
					MiraText.dashboardFeedbackSpeedTestFailedTitle.localized(language),
					description: message
				)
			)
		} catch {
			let message = MiraText.speedTestErrorNetworkUnavailable.localized(language)

			speedTestProgress = 0
			currentSpeedValueText = "0.0"

			sonner.show(
				.error(
					MiraText.dashboardFeedbackSpeedTestFailedTitle.localized(language),
					description: message
				)
			)
		}
	}

	private func showAuthenticationFeedback(for error: AuthError) {
		switch error {
		case .unavailable(let message):
			sonner.show(
				.error(
					MiraText.dashboardFeedbackAuthUnavailableTitle.localized(language),
					description: message
				)
			)

		case .failed(let message):
			sonner.show(
				.rejected(
					MiraText.dashboardFeedbackAuthRejectedTitle.localized(language),
					description: message.isEmpty
						? MiraText.dashboardFeedbackAuthRejectedDescription.localized(language)
						: message
				)
			)

		case .cancelled:
			break
		}
	}
}

#Preview {
	DashboardView()
}
