import SwiftUI

struct NetworkChartTooltip: View {
	@Environment(\.miraLanguage) private var language

	let kind: NetworkTrafficKind
	let point: NetworkUsagePoint

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(point.timestamp, format: .dateTime.hour().minute().second())
				.font(.caption)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

			HStack(spacing: 6) {
				Circle()
					.fill(kind.color)
					.frame(width: 8, height: 8)

				Text(kind.title(language: language))
					.font(.caption)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

				Text(ByteFormatters.speed(kind.speed(from: point)))
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
}
