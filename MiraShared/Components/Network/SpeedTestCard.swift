import SwiftUI

struct SpeedTestCard: View {
	let displayedSpeedValueText: String
	let progress: Double
	let isTesting: Bool
	let isFinished: Bool
	let errorMessage: String?
	let onStartTest: () -> Void

	var body: some View {
		MiraCard {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
				header

				Divider()

				HStack {
					Spacer()

					RadialSpeedChart(
						valueText: displayedSpeedValueText,
						subtitle: "Mbps",
						progress: progress,
						isTesting: isTesting,
						isFinished: isFinished,
						action: onStartTest
					)

					Spacer()
				}

				if let errorMessage {
					Text(errorMessage)
						.font(.subheadline)
						.foregroundStyle(MiraTheme.ColorToken.destructive)
				}
			}
		}
	}

	private var header: some View {
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
	}
}
