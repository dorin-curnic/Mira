import Charts
import SwiftUI

struct NetworkTrafficChart: View {
	@Environment(\.miraLanguage) private var language

	let kind: NetworkTrafficKind
	let speedText: String
	let totalText: String
	let points: [NetworkUsagePoint]

	@State private var selectedPoint: NetworkUsagePoint?

	private var now: Date {
		Date()
	}

	private var visibleStartDate: Date {
		now.addingTimeInterval(-300)
	}

	private var visibleEndDate: Date {
		now
	}

	private var filteredPoints: [NetworkUsagePoint] {
		points.filter {
			$0.timestamp >= visibleStartDate && $0.timestamp <= visibleEndDate
		}
	}

	var body: some View {
		MiraCard {
			VStack(alignment: .leading, spacing: 0) {
				header

				Divider()
					.padding(.vertical, MiraTheme.Spacing.md)

				chart
					.frame(height: 250)
			}
		}
	}

	private var header: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			HStack(alignment: .firstTextBaseline) {
				Text(kind.title(language: language))
					.font(MiraTheme.Typography.cardTitle)
					.fontWeight(MiraTheme.Typography.cardTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)

				Spacer()

				Text(speedText)
					.font(MiraTheme.Typography.rowValue)
					.fontWeight(MiraTheme.Typography.rowTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
			}

			Text(
				String(
					format: MiraText.networkTotalFormat.localized(language),
					MiraText.total.localized(language),
					totalText
				)
			)
			.font(MiraTheme.Typography.rowSubtitle)
			.fontWeight(MiraTheme.Typography.rowValueWeight)
			.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			.padding(.top, MiraTheme.Spacing.xs)
		}
	}

	private var chart: some View {
		Chart {
			chartMarks
			selectionMarks
		}
		.chartXScale(domain: visibleStartDate...visibleEndDate)
		.chartYScale(domain: 0...maxYValue)
		.chartXAxis {
			xAxisMarks
		}
		.chartYAxis {
			yAxisMarks
		}
		.chartLegend(.hidden)
		.chartOverlay { proxy in
			chartInteractionOverlay(proxy: proxy)
		}
		.overlay(alignment: .topLeading) {
			if let selectedPoint {
				NetworkChartTooltip(kind: kind, point: selectedPoint)
					.padding(.top, MiraTheme.Spacing.sm)
					.padding(.leading, MiraTheme.Spacing.sm)
			}
		}
		.overlay {
			if filteredPoints.isEmpty {
				Text(MiraText.collectingNetworkData.localized(language))
					.font(MiraTheme.Typography.cardSubtitle)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
	}

	@ChartContentBuilder
	private var chartMarks: some ChartContent {
		ForEach(filteredPoints) { point in
			AreaMark(
				x: .value(MiraText.networkChartTime.localized(language), point.timestamp),
				yStart: .value(MiraText.networkChartMinimum.localized(language), 0),
				yEnd: .value(kind.title(language: language), kind.speed(from: point))
			)
			.foregroundStyle(areaGradient)
			.interpolationMethod(.catmullRom)

			LineMark(
				x: .value(MiraText.networkChartTime.localized(language), point.timestamp),
				y: .value(kind.title(language: language), kind.speed(from: point))
			)
			.foregroundStyle(kind.color)
			.lineStyle(
				StrokeStyle(
					lineWidth: 2.4,
					lineCap: .round,
					lineJoin: .round
				)
			)
			.interpolationMethod(.catmullRom)
		}
	}

	@ChartContentBuilder
	private var selectionMarks: some ChartContent {
		if let selectedPoint {
			RuleMark(
				x: .value(MiraText.networkChartSelectedTime.localized(language), selectedPoint.timestamp)
			)
			.foregroundStyle(MiraTheme.ColorToken.mutedForeground.opacity(0.35))
			.lineStyle(
				StrokeStyle(
					lineWidth: 1,
					dash: [4, 4]
				)
			)

			PointMark(
				x: .value(MiraText.networkChartSelectedTime.localized(language), selectedPoint.timestamp),
				y: .value(kind.title(language: language), kind.speed(from: selectedPoint))
			)
			.foregroundStyle(kind.color)
			.symbolSize(60)
		}
	}

	private var xAxisMarks: some AxisContent {
		AxisMarks(values: .automatic(desiredCount: 4)) { _ in
			AxisGridLine()
				.foregroundStyle(MiraTheme.ColorToken.border)

			AxisValueLabel(format: .dateTime.minute().second())
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private var yAxisMarks: some AxisContent {
		AxisMarks(position: .leading) { value in
			AxisGridLine()
				.foregroundStyle(MiraTheme.ColorToken.border)

			if let doubleValue = value.as(Double.self) {
				AxisValueLabel {
					Text(ByteFormatters.speed(doubleValue))
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}
			}
		}
	}

	private var areaGradient: LinearGradient {
		LinearGradient(
			colors: [
				kind.color.opacity(0.55),
				kind.color.opacity(0.08),
			],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	private var maxYValue: Double {
		let maxPoint =
			filteredPoints
			.map { kind.speed(from: $0) }
			.max() ?? 1

		return max(maxPoint * 1.25, 1024)
	}

	private func chartInteractionOverlay(proxy: ChartProxy) -> some View {
		GeometryReader { geometry in
			Rectangle()
				.fill(.clear)
				.contentShape(Rectangle())
				.gesture(
					DragGesture(minimumDistance: 0)
						.onChanged { value in
							updateSelectedPoint(
								at: value.location,
								proxy: proxy,
								geometry: geometry
							)
						}
						.onEnded { _ in
							selectedPoint = nil
						}
				)
		}
	}

	private func updateSelectedPoint(
		at location: CGPoint,
		proxy: ChartProxy,
		geometry: GeometryProxy
	) {
		let plotFrame: CGRect

		if #available(iOS 17.0, macOS 14.0, *) {
			guard let plotFrameAnchor = proxy.plotFrame else {
				selectedPoint = nil
				return
			}

			plotFrame = geometry[plotFrameAnchor]
		} else {
			plotFrame = geometry[proxy.plotAreaFrame]
		}

		let xPosition = location.x - plotFrame.origin.x

		guard xPosition >= 0, xPosition <= plotFrame.width else {
			selectedPoint = nil
			return
		}

		guard let selectedDate: Date = proxy.value(atX: xPosition) else {
			selectedPoint = nil
			return
		}

		selectedPoint = nearestPoint(to: selectedDate)
	}

	private func nearestPoint(to date: Date) -> NetworkUsagePoint? {
		filteredPoints.min {
			abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
		}
	}
}
