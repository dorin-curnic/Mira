import SwiftUI

struct ContentView: View {
	@State private var statusText = "Not authenticated"
	@State private var isAuthenticating = false

	private let authService = AuthService()

	var body: some View {
		VStack(spacing: 16) {
			Text("Mira")
				.font(.largeTitle)
				.fontWeight(.bold)

			Text("University Wi-Fi authentication helper")
				.foregroundStyle(.secondary)

			Text(statusText)
				.font(.callout)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)

			Button {
				Task {
					await authenticate()
				}
			} label: {
				if isAuthenticating {
					ProgressView()
				} else {
					Text("Authenticate")
				}
			}
			.buttonStyle(.borderedProminent)
			.disabled(isAuthenticating)
		}
		.padding()
		.frame(minWidth: 320, minHeight: 240)
	}

	private func authenticate() async {
		isAuthenticating = true
		statusText = "Waiting for authentication..."

		defer {
			isAuthenticating = false
		}

		do {
			let success = try await authService.authenticate()

			if success {
				statusText = "Authentication successful"
			}
		} catch {
			statusText = error.localizedDescription
		}
	}
}

#Preview {
	ContentView()
}
