import SwiftUI

struct UsageView: View {
	private let downloadSeries: [CGFloat] = [
		0.70, 0.18, 0.15, 0.17, 0.16, 0.18, 0.17, 0.16, 0.21, 0.34,
		0.75, 0.14, 0.16, 0.15, 0.14, 0.16, 0.15, 0.16, 0.20, 0.31,
		0.36, 0.14, 0.18, 0.15, 0.14, 0.13, 0.17, 0.16, 0.35, 0.20,
		0.22, 0.16, 0.16
	]

	private let uploadSeries: [CGFloat] = [
		0.72, 0.15, 0.14, 0.16, 0.14, 0.17, 0.13, 0.14, 0.25, 0.24,
		0.18, 0.18, 0.16, 0.15, 0.18, 0.17, 0.21, 0.42, 0.28, 0.19,
		0.16, 0.20, 0.17, 0.23, 0.20, 0.22, 0.18, 0.19, 0.18, 0.21,
		0.20, 0.19, 0.18
	]

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
				pageHeader
				connectedTimeCard

				LazyVGrid(
					columns: [
						GridItem(.flexible()),
						GridItem(.flexible())
					],
					spacing: MiraTheme.Spacing.md
				) {
					NetworkTrafficCard(
						title: "Download",
						total: "252,3 MB",
						speed: "511 bytes/sec",
						series: downloadSeries,
						accentColor: Color(red: 126 / 255, green: 151 / 255, blue: 255 / 255)
					)

					NetworkTrafficCard(
						title: "Upload",
						total: "155,2 MB",
						speed: "Zero KB/sec",
						series: uploadSeries,
						accentColor: Color(red: 255 / 255, green: 98 / 255, blue: 106 / 255)
					)
				}
			}
			.padding(MiraTheme.Spacing.xl)
			.frame(maxWidth: 820)
			.frame(maxWidth: .infinity)
		}
		.background(MiraTheme.ColorToken.background)
	}

	private var pageHeader: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text("Usage")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text("Track connection time and network traffic.")
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private var connectedTimeCard: some View {
		MiraCard {
			HStack {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					Text("Connected Time")
						.font(.subheadline)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

					Text("00:00:00")
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundStyle(MiraTheme.ColorToken.foreground)
				}

				Spacer()

				Image(systemName: "clock")
					.font(.title2)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
	}
}

private struct NetworkTrafficCard: View {
	let title: String
	let total: String
	let speed: String
	let series: [CGFloat]
	let accentColor: Color

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
			Text(title)
				.font(.title2)
				.fontWeight(.bold)
				.foregroundStyle(.white)

			HStack {
				Text(total)
					.font(.title3)
					.foregroundStyle(.white.opacity(0.88))

				Spacer()

				Text(speed)
					.font(.title3)
					.foregroundStyle(.white.opacity(0.88))
			}

			Sparkline(series: series, color: accentColor)
				.frame(height: 82)
				.padding(.top, MiraTheme.Spacing.sm)
		}
		.padding(MiraTheme.Spacing.lg)
		.background(
			LinearGradient(
				colors: [
					Color(red: 43 / 255, green: 26 / 255, blue: 92 / 255),
					Color(red: 82 / 255, green: 38 / 255, blue: 143 / 255)
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
		)
		.clipShape(RoundedRectangle(cornerRadius: MiraTheme.Radius.xl, style: .continuous))
		.overlay {
			RoundedRectangle(cornerRadius: MiraTheme.Radius.xl, style: .continuous)
				.stroke(Color.white.opacity(0.08), lineWidth: 1)
		}
	}
}

private struct Sparkline: View {
	let series: [CGFloat]
	let color: Color

	var body: some View {
		GeometryReader { geometry in
			let width = geometry.size.width
			let height = geometry.size.height
			let step = width / CGFloat(max(series.count - 1, 1))

			Path { path in
				for index in series.indices {
					let x = CGFloat(index) * step
					let normalized = min(max(series[index], 0), 1)
					let y = height - normalized * height

					if index == series.startIndex {
						path.move(to: CGPoint(x: x, y: y))
					} else {
						path.addLine(to: CGPoint(x: x, y: y))
					}
				}
			}
			.stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
		}
	}
}

#Preview {
	UsageView()
}
