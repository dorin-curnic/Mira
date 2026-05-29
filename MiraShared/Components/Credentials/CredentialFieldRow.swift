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

	private var rawDisplayValue: String {
		isHiddenSensitiveValue
		? String(repeating: "•", count: max(value.count, 12))
		: value
	}

	private var displayValue: String {
		guard isActive else {
			return rawDisplayValue
		}

		return rawDisplayValue.addingSoftBreaks(every: 1)
	}

	var body: some View {
		Button(action: onTap) {
			HStack(alignment: .top, spacing: 0) {
				titleText

				Spacer(minLength: MiraTheme.Spacing.md)

				valueText
			}
			.padding(.vertical, MiraTheme.Spacing.md)
			.contentShape(Rectangle())
			.disableAnimations()
		}
		.buttonStyle(.plain)
		.disableAnimations()
	}

	private var titleText: some View {
		Text(title)
			.font(.body)
			.fontWeight(.semibold)
			.foregroundStyle(MiraTheme.ColorToken.foreground)
			.fixedSize(horizontal: true, vertical: false)
	}

	private var valueText: some View {
		Text(displayValue)
			.font(isHiddenSensitiveValue ? .title3 : .body)
			.fontWeight(isHiddenSensitiveValue ? .black : .semibold)
			.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			.multilineTextAlignment(.leading)
			.lineLimit(isActive ? 2 : 1)
			.truncationMode(.tail)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.disableAnimations()
	}
}
