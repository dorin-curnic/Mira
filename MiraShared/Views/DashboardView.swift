import SwiftUI

struct DashboardView: View {
	@Environment(\.miraLanguage) private var language

	@State private var connectionStatus: WiFiConnectionStatus = .disconnected
	@State private var isAuthenticating = false
	@State private var userAllowsAutoReconnect = false

	@State private var isSpeedTesting = false
	@State private var speedTestResult: SpeedTestResult?
	@State private var speedTestError: String?
	@State private var currentSpeedValueText = "0.0"
	@State private var speedTestProgress = 0.0

	private var connectionActionTitle: String {
		let text: MiraText = connectionStatus == .connected ? .disconnect : .connect
		return text.localized(language)
	}

	private var connectionActionTint: Color {
		connectionStatus == .connected
		? MiraTheme.ColorToken.destructive
		: MiraTheme.ColorToken.primary
	}

	private let authService = AuthService()
	private let speedTestService = SpeedTestService()

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
				pageHeader
				wifiStatusCard
				connectionActionButton
				speedTestCard
			}
			.padding(MiraTheme.Spacing.xl)
			.frame(maxWidth: 820)
			.frame(maxWidth: .infinity)
		}
		.background(MiraTheme.ColorToken.background)
	}

	private var pageHeader: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text(.dashboardTitle, language: language)
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text(.dashboardSubtitle, language: language)
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
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
						.fontWeight(.semibold)
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
					Text(.wifiName, language: language)
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundStyle(MiraTheme.ColorToken.foreground)

					Spacer()

					MiraBadge(status: connectionStatus)
				}

				Spacer()

				Text(.wifiDescription, language: language)
					.font(.subheadline)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
	}

	private var speedTestCard: some View {
		SpeedTestCard(
			displayedSpeedValueText: displayedSpeedValueText,
			progress: speedTestProgress,
			isTesting: isSpeedTesting,
			isFinished: speedTestResult != nil,
			errorMessage: speedTestError,
			onStartTest: {
				Task {
					await runSpeedTest()
				}
			}
		)
	}

	private func connect() async {
		isAuthenticating = true
		connectionStatus = .pending

		defer {
			isAuthenticating = false
		}

		do {
			try await authService.authenticate(
				reason: MiraText.authenticateReason.localized(language)
			)

			userAllowsAutoReconnect = true
			connectionStatus = .connected
		} catch {
			userAllowsAutoReconnect = false
			connectionStatus = .rejected
		}
	}

	private func disconnect() {
		userAllowsAutoReconnect = false
		connectionStatus = .disconnected
	}

	private var displayedSpeedValueText: String {
		if isSpeedTesting {
			return currentSpeedValueText
		}

		return speedTestResult?.speedValueText ?? "0.0"
	}

	private func runSpeedTest() async {
		guard !isSpeedTesting else {
			return
		}

		isSpeedTesting = true
		speedTestError = nil
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
		} catch {
			speedTestError = error.localizedDescription
			speedTestProgress = 0
			currentSpeedValueText = "0.0"
		}
	}
}

#Preview {
	DashboardView()
}
