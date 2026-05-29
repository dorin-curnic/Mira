import SwiftUI

struct NetworkView: View {
	@ObservedObject var networkUsageService: NetworkUsageService

	var body: some View {
		GeometryReader { geometry in
			ScrollView {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
					pageHeader
					connectionStatusCard
					trafficCharts(isCompact: geometry.size.width < 640)
				}
				.padding(MiraTheme.Spacing.xl)
				.frame(maxWidth: 980)
				.frame(maxWidth: .infinity)
			}
			.background(MiraTheme.ColorToken.background)
		}
	}

	private var pageHeader: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text("Network")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text("Track the usage of the connection.")
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private var connectionStatusCard: some View {
		MiraCard {
			HStack {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					Text("UTM Wi-Fi")
						.font(.title3)
						.fontWeight(.semibold)

					Text("Wi-Fi Connection")
						.font(.subheadline)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}

				Spacer()

				Text(networkUsageService.connectedTimeText)
					.fontWeight(.medium)
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
