import SwiftUI

struct CredentialFieldRow: View {
	let field: CredentialField
	let title: String
	let value: String
	let isSensitive: Bool
	let isRevealed: Bool
	let isActive: Bool
	let onTap: () -> Void

	private var isHiddenSensitiveValue: Bool {
		isSensitive && !isRevealed
	}

	private var displayValue: String {
		if isHiddenSensitiveValue {
			return String(repeating: "•", count: max(value.count, 12))
		}

		return value
	}

	var body: some View {
		Button(action: onTap) {
			HStack(alignment: .firstTextBaseline, spacing: MiraTheme.Spacing.md) {
				titleText

				Spacer(minLength: MiraTheme.Spacing.md)

				valueText
			}
			.padding(.vertical, MiraTheme.Spacing.md)
			.contentShape(Rectangle())
			.background {
				if isActive {
					RoundedRectangle(
						cornerRadius: MiraTheme.Radius.md,
						style: .continuous
					)
					.fill(MiraTheme.ColorToken.secondary.opacity(0.65))
				}
			}
		}
		.buttonStyle(.plain)
	}

	private var titleText: some View {
		Text(title)
			.font(MiraTheme.Typography.rowTitle)
			.fontWeight(MiraTheme.Typography.rowTitleWeight)
			.foregroundStyle(MiraTheme.ColorToken.foreground)
			.fixedSize(horizontal: true, vertical: false)
	}

	private var valueText: some View {
		Text(displayValue)
			.font(MiraTheme.Typography.rowValue)
			.fontWeight(MiraTheme.Typography.rowValueWeight)
			.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			.multilineTextAlignment(.trailing)
			.lineLimit(1)
			.truncationMode(.middle)
			.frame(maxWidth: .infinity, alignment: .trailing)
	}
}
