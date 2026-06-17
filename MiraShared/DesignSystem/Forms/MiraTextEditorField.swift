import SwiftUI

struct MiraTextEditorField: View {
	let label: String
	let placeholder: String?
	let errorText: String?
	let minHeight: CGFloat

	@Binding var text: String

	init(
		label: String,
		placeholder: String? = nil,
		text: Binding<String>,
		errorText: String? = nil,
		minHeight: CGFloat = 140
	) {
		self.label = label
		self.placeholder = placeholder
		self._text = text
		self.errorText = errorText
		self.minHeight = minHeight
	}

	private var isInvalid: Bool {
		errorText != nil
	}

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			MiraFieldLabel(label)

			ZStack(alignment: .topLeading) {
				if let placeholder, text.isEmpty {
					Text(placeholder)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
						.padding(.horizontal, MiraTheme.Spacing.xs)
						.padding(.vertical, MiraTheme.Spacing.sm)
				}

				TextEditor(text: $text)
					.frame(minHeight: minHeight)
					.scrollContentBackground(.hidden)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
					.tint(MiraTheme.ColorToken.primary)
			}
			.padding(MiraTheme.Spacing.sm)
			.background(MiraTheme.ColorToken.secondary)
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
				.stroke(
					isInvalid
					? MiraTheme.ColorToken.destructive
					: MiraTheme.ColorToken.border,
					lineWidth: 1
				)
			}

			if let errorText {
				MiraHelperText(errorText, tone: .destructive)
			}
		}
	}
}
