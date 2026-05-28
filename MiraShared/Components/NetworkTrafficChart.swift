import SwiftUI
import Charts

enum NetworkTrafficKind {
	case download
	case upload

	var title: String {
		switch self {
		case .download:
			return "Download"
		case .upload:
			return "Upload"
		}
	}

	var color: Color {
		switch self {
		case .download:
			return MiraTheme.ColorToken.chart2
		case .upload:
			return MiraTheme.ColorToken.chart5
		}
	}

	func speed(from point: NetworkUsagePoint) -> Double {
		switch self {
		case .download:
			return point.downloadBytesPerSecond
		case .upload:
			return point.uploadBytesPerSecond
		}
	}
}

struct NetworkTrafficChart: View {
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
				Text(kind.title)
					.font(.title3)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.foreground)

				Spacer()

				Text(speedText)
					.font(.subheadline)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
			}

			Text("Total: \(totalText)")
				.font(.caption)
				.fontWeight(.medium)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				.padding(.top, MiraTheme.Spacing.xs)
		}
	}

	private var chart: some View {

		Chart {
			ForEach(filteredPoints) { point in
				AreaMark(
					x: .value("Time", point.timestamp),
					yStart: .value("Minimum", 0),
					yEnd: .value(kind.title, kind.speed(from: point))
				)
				.foregroundStyle(areaGradient)
				.interpolationMethod(.catmullRom)
				LineMark(
					x: .value("Time", point.timestamp),
					y: .value(kind.title, kind.speed(from: point))
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
			if let selectedPoint {
				RuleMark(
					x: .value("Selected Time", selectedPoint.timestamp)
				)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground.opacity(0.35))
				.lineStyle(
					StrokeStyle(
						lineWidth: 1,
						dash: [4, 4]
					)
				)
				PointMark(
					x: .value("Selected Time", selectedPoint.timestamp),
					y: .value(kind.title, kind.speed(from: selectedPoint))
				)
				.foregroundStyle(kind.color)
				.symbolSize(60)
			}
		}
		.chartXScale(domain: visibleStartDate...visibleEndDate)
		.chartYScale(domain: 0...maxYValue)
		.chartXAxis {
			AxisMarks(values: .automatic(desiredCount: 4)) { _ in
				AxisGridLine()
					.foregroundStyle(MiraTheme.ColorToken.border)
				AxisValueLabel(format: .dateTime.minute().second())
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
		.chartYAxis {
			AxisMarks(position: .leading) { value in
				AxisGridLine()
					.foregroundStyle(MiraTheme.ColorToken.border)
				if let doubleValue = value.as(Double.self) {
					AxisValueLabel {
						Text(formatChartBytes(doubleValue))
							.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					}
				}
			}
		}
		.chartLegend(.hidden)
		.chartOverlay { proxy in
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
		.overlay(alignment: .topLeading) {
			if let selectedPoint {
				chartTooltip(for: selectedPoint)
					.padding(.top, MiraTheme.Spacing.sm)
					.padding(.leading, MiraTheme.Spacing.sm)
			}
		}
		.overlay {
			if filteredPoints.isEmpty {
				Text("Collecting network data...")
					.font(.subheadline)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
		}
	}
	private var areaGradient: LinearGradient {
		LinearGradient(
			colors: [
				kind.color.opacity(0.55),
				kind.color.opacity(0.08)
			],
			startPoint: .top,
			endPoint: .bottom
		)
	}
	private var maxYValue: Double {
		let maxPoint = filteredPoints
			.map { kind.speed(from: $0) }
			.max() ?? 1
		return max(maxPoint * 1.25, 1024)
	}
	private func updateSelectedPoint(
		at location: CGPoint,
		proxy: ChartProxy,
		geometry: GeometryProxy
	) {
		let plotFrame: CGRect
		if #available(iOS 17.0, macOS 14.0, *) {
			plotFrame = geometry[proxy.plotFrame!]
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
			abs($0.timestamp.timeIntervalSince(date)) <
				abs($1.timestamp.timeIntervalSince(date))
		}
	}
	private func chartTooltip(for point: NetworkUsagePoint) -> some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(point.timestamp, format: .dateTime.hour().minute().second())
				.font(.caption)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			HStack(spacing: 6) {
				Circle()
					.fill(kind.color)
					.frame(width: 8, height: 8)
				Text(kind.title)
					.font(.caption)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				Text(formatChartBytes(kind.speed(from: point)))
					.font(.caption)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
			}
		}
		.padding(.horizontal, 12)
		.padding(.vertical, 10)
		.background(.regularMaterial)
		.clipShape(
			RoundedRectangle(
				cornerRadius: MiraTheme.Radius.md,
				style: .continuous
			)
		)
		.overlay {
			RoundedRectangle(
				cornerRadius: MiraTheme.Radius.md,
				style: .continuous
			)
			.stroke(MiraTheme.ColorToken.border, lineWidth: 1)
		}
		.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
	}
	private func formatChartBytes(_ bytes: Double) -> String {
		if bytes <= 0 {
			return "Zero KB/s"
		}
		let value = UInt64(max(bytes, 0))
		let formatter = ByteCountFormatter()
		formatter.countStyle = .binary
		formatter.allowedUnits = [.useKB, .useMB, .useGB]
		formatter.includesUnit = true
		formatter.isAdaptive = true
		return formatter.string(fromByteCount: Int64(value)) + "/s"
	}

}
