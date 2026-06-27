import SwiftUI

struct MiraTextField: View {
	enum Keyboard {
		case text
		case email
	}

	let label: String
	let placeholder: String
	let errorText: String?
	let keyboard: Keyboard

	@Binding var text: String

	init(
		label: String,
		placeholder: String,
		text: Binding<String>,
		errorText: String? = nil,
		keyboard: Keyboard = .text
	) {
		self.label = label
		self.placeholder = placeholder
		self._text = text
		self.errorText = errorText
		self.keyboard = keyboard
	}

	private var isInvalid: Bool {
		errorText != nil
	}

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			MiraFieldLabel(label)

			TextField(
				LocalizedStringKey("form.input"),
				text: $text,
				prompt: Text(verbatim: placeholder)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			)
			.foregroundStyle(MiraTheme.ColorToken.foreground)
			#if os(iOS)
				.textInputAutocapitalization(.never)
				.keyboardType(keyboard == .email ? .emailAddress : .default)
				.autocorrectionDisabled()
			#endif
			.tint(MiraTheme.ColorToken.primary)
			.miraFormInputChrome(isInvalid: isInvalid)

			if let errorText {
				MiraHelperText(errorText, tone: .destructive)
			}
		}
	}
}
