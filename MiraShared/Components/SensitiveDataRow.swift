import SwiftUI

struct SensitiveDataRow: View {
	let title: String
	let value: String
	let isSensitive: Bool
	let isRevealed: Bool

	private var displayedValue: String {
		if isSensitive && !isRevealed {
			return String(repeating: "•", count: max(value.count, 8))
		}

		return value
	}

	var body: some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			Text(title)
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

			Spacer()

			Text(displayedValue)
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.lineLimit(1)
		}
	}
}
