import SwiftUI

struct DashboardView: View {
	@State private var connectionStatus: WiFiConnectionStatus = .disconnected
	@State private var isAuthenticating = false
	@State private var userAllowsAutoReconnect = false

	@State private var isSpeedTesting = false
	@State private var speedTestResult: SpeedTestResult?
	@State private var speedTestError: String?
	@State private var currentSpeedMbps = 0.0
	@State private var currentSpeedValueText = "0.0"
	@State private var speedTestProgress = 0.0

	private var connectionActionTitle: String {
		connectionStatus == .connected ? "Disconnect" : "Connect"
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
			Text("Dashboard")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text("Connect to university Wi-Fi.")
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
					Text("UTM Wi-Fi")
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundStyle(MiraTheme.ColorToken.foreground)

					Spacer()

					MiraBadge(status: connectionStatus)
				}

				Spacer()

				Text("Connect to the UTM-WiNetUni_Auth Wi-Fi, and check the status of the connection")
					.font(.subheadline)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
	}

	private var speedTestCard: some View {
		MiraCard {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
				HStack(alignment: .top, spacing: MiraTheme.Spacing.md) {
					VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
						Text("Speed Test")
							.font(.title3)
							.fontWeight(.semibold)
							.foregroundStyle(MiraTheme.ColorToken.foreground)

						Text("Mira downloads a small test file to analyse your network.")
							.font(.subheadline)
							.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					}

					Spacer()

					Image(systemName: "speedometer")
						.font(.title3)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}

				Divider()

				HStack {
					Spacer()

					RadialChart(
						valueText: displayedSpeedValueText,
						subtitle: "Mbps",
						progress: speedTestProgress,
						isTesting: isSpeedTesting,
						isFinished: speedTestResult != nil,
						action: {
							Task {
								await runSpeedTest()
							}
						}
					)

					Spacer()
				}

				if let speedTestError {
					Text(speedTestError)
						.font(.subheadline)
						.foregroundStyle(MiraTheme.ColorToken.destructive)
				}
			}
		}
	}

	private func connect() async {
		isAuthenticating = true
		connectionStatus = .pending

		defer {
			isAuthenticating = false
		}

		do {
			let success = try await authService.authenticate(
				reason: "Authenticate to securely connect to university Wi-Fi."
			)

			if success {
				userAllowsAutoReconnect = true
				connectionStatus = .connected
			}
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
		currentSpeedMbps = 0
		currentSpeedValueText = "0.0"
		speedTestProgress = 0

		defer {
			isSpeedTesting = false
		}

		do {
			for try await event in speedTestService.runDownloadTest() {
				switch event {
				case .progress(let progress):
					currentSpeedMbps = progress.currentMegabitsPerSecond
					currentSpeedValueText = progress.speedValueText
					speedTestProgress = progress.progress

				case .completed(let result):
					speedTestResult = result
					currentSpeedMbps = result.finalMegabitsPerSecond
					currentSpeedValueText = result.speedValueText
					speedTestProgress = 1
				}
			}
		} catch {
			speedTestError = error.localizedDescription
			speedTestProgress = 0
			currentSpeedMbps = 0
			currentSpeedValueText = "0.0"
		}
	}
}

#Preview {
	DashboardView()
}
