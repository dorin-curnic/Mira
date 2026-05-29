import SwiftUI

struct RadialChart: View {
	let valueText: String
	let subtitle: String
	let progress: Double
	let isTesting: Bool
	let isFinished: Bool
	let action: () -> Void

	private var displayedProgress: Double {
		min(max(progress, 0), 1)
	}

	private var ringColor: Color {
		isFinished ? MiraTheme.ColorToken.chart2 : MiraTheme.ColorToken.chart4
	}

	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				Circle()
					.stroke(
						MiraTheme.ColorToken.muted,
						lineWidth: 16
					)

				Circle()
					.trim(from: 0, to: displayedProgress)
					.stroke(
						ringColor,
						style: StrokeStyle(
							lineWidth: 16,
							lineCap: .round,
							lineJoin: .round
						)
					)
					.rotationEffect(.degrees(-90))
					.animation(.linear(duration: 0.12), value: displayedProgress)
					.animation(.easeInOut(duration: 0.2), value: isFinished)

				VStack(spacing: 6) {
					Text(valueText)
						.font(.system(size: 42, weight: .bold, design: .rounded))
						.foregroundStyle(MiraTheme.ColorToken.foreground)
						.monospacedDigit()

					Text(subtitle)
						.font(.subheadline)
						.fontWeight(.medium)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}
			}
			.frame(width: 220, height: 220)
			.padding(.vertical, MiraTheme.Spacing.md)
		}
		.buttonStyle(.plain)
		.disabled(isTesting)
	}
}
