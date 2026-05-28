import SwiftUI

struct DashboardView: View {
	@State private var connectionStatus: WiFiConnectionStatus = .disconnected
	@State private var isAuthenticating = false
	@State private var userAllowsAutoReconnect = false

	private var connectionActionTitle: String {
		connectionStatus == .connected ? "Disconnect" : "Connect"
	}

	private var connectionActionTint: Color {
		connectionStatus == .connected
		? MiraTheme.ColorToken.destructive
		: MiraTheme.ColorToken.primary
	}

	private let authService = AuthService()

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
				pageHeader

				wifiStatusCard
				connectionActionButton
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
}

#Preview {
	DashboardView()
}
