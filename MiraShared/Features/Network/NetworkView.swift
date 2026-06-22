import SwiftUI

struct NetworkView: View {
	@Environment(\.miraLanguage) private var language

	@ObservedObject var networkUsageService: NetworkUsageService

	var body: some View {
		GeometryReader { geometry in
			MiraPageContainer(maxWidth: MiraTheme.Layout.widePageMaxWidth) {
				pageHeader
				connectionStatusCard
				trafficCharts(isCompact: geometry.size.width < 640)
			}
		}
	}

	private var pageHeader: some View {
		MiraPageHeader(
			MiraText.networkTitle.localized(language),
			subtitle: MiraText.networkSubtitle.localized(language)
		)
	}

	private var connectionStatusCard: some View {
		MiraCard {
			HStack {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					Text(MiraText.wifiName.localized(language))
						.font(MiraTheme.Typography.cardTitle)
						.fontWeight(MiraTheme.Typography.cardTitleWeight)

					Text(MiraText.wifiConnection.localized(language))
						.font(MiraTheme.Typography.cardSubtitle)
						.fontWeight(MiraTheme.Typography.cardSubtitleWeight)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}

				Spacer()

				Text(networkUsageService.connectedTimeText)
					.font(MiraTheme.Typography.rowValue)
					.fontWeight(MiraTheme.Typography.rowValueWeight)
			}
		}
	}

	private func trafficCharts(isCompact: Bool) -> some View {
		LazyVGrid(
			columns: Array(
				repeating: GridItem(.flexible()),
				count: isCompact ? 1 : 2
			),
			spacing: MiraTheme.Spacing.md
		) {
			NetworkTrafficChart(
				kind: .download,
				speedText: networkUsageService.downloadSpeedText,
				totalText: networkUsageService.downloadedTotalText,
				points: networkUsageService.points
			)

			NetworkTrafficChart(
				kind: .upload,
				speedText: networkUsageService.uploadSpeedText,
				totalText: networkUsageService.uploadedTotalText,
				points: networkUsageService.points
			)
		}
	}
}

#Preview {
	NetworkView(networkUsageService: NetworkUsageService())
}
