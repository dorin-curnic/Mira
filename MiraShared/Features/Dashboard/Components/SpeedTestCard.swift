import SwiftUI

struct SpeedTestCard: View {
	@Environment(\.miraLanguage) private var language

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
						subtitle: MiraText.mbps.localized(language),
						progress: progress,
						isTesting: isTesting,
						isFinished: isFinished,
						action: onStartTest
					)

					Spacer()
				}

				if let errorMessage {
					Text(errorMessage)
						.font(MiraTheme.Typography.cardSubtitle)
						.fontWeight(MiraTheme.Typography.cardSubtitleWeight)
						.foregroundStyle(MiraTheme.ColorToken.destructive)
				}
			}
		}
	}

	private var header: some View {
		HStack(alignment: .top, spacing: MiraTheme.Spacing.md) {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
				Text(.speedTestTitle, language: language)
					.font(MiraTheme.Typography.cardTitle)
					.fontWeight(MiraTheme.Typography.cardTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)

				Text(.speedTestDescription, language: language)
					.font(MiraTheme.Typography.cardSubtitle)
					.fontWeight(MiraTheme.Typography.cardSubtitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}

			Spacer()

			Image(systemName: "speedometer")
				.font(MiraTheme.Typography.cardIcon)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}
}
