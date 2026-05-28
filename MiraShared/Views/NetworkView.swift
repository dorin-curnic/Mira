import SwiftUI

struct NetworkView: View {
	@ObservedObject var networkUsageService: NetworkUsageService

	var body: some View {
		GeometryReader { geometry in
			ScrollView {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
					pageHeader
					connectedTimeCard
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

	private var connectedTimeCard: some View {
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

private struct NetworkSummaryCard: View {
	let title: String
	let value: String
	let icon: String

	var body: some View {
		MiraCard {
			HStack(spacing: MiraTheme.Spacing.md) {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					Text(title)
						.font(.subheadline)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

					Text(value)
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundStyle(MiraTheme.ColorToken.foreground)
				}

				Spacer()

				Image(systemName: icon)
					.font(.title3)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
	}
}

#Preview {
	NetworkView(networkUsageService: NetworkUsageService())
}
