import SwiftUI

struct MiraPasswordField: View {
	let label: String
	let placeholder: String
	let errorText: String?

	@Binding var text: String
	@State private var isPasswordVisible = false

	init(
		label: String,
		placeholder: String,
		text: Binding<String>,
		errorText: String? = nil
	) {
		self.label = label
		self.placeholder = placeholder
		self._text = text
		self.errorText = errorText
	}

	private var isInvalid: Bool {
		errorText != nil
	}

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			MiraFieldLabel(label)

			HStack(spacing: MiraTheme.Spacing.sm) {
				passwordInput

				Button {
					isPasswordVisible.toggle()
				} label: {
					Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}
				.buttonStyle(.plain)
			}
			.miraFormInputChrome(isInvalid: isInvalid)

			if let errorText {
				MiraHelperText(errorText, tone: .destructive)
			}
		}
	}

	@ViewBuilder
	private var passwordInput: some View {
		if isPasswordVisible {
			TextField(
				LocalizedStringKey("form.input"),
				text: $text,
				prompt: Text(verbatim: placeholder)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			)
			.foregroundStyle(MiraTheme.ColorToken.foreground)
#if os(iOS)
			.textInputAutocapitalization(.never)
			.autocorrectionDisabled()
#endif
			.tint(MiraTheme.ColorToken.primary)
		} else {
			SecureField(
				LocalizedStringKey("form.input"),
				text: $text,
				prompt: Text(verbatim: placeholder)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			)
			.foregroundStyle(MiraTheme.ColorToken.foreground)
#if os(iOS)
			.textInputAutocapitalization(.never)
			.autocorrectionDisabled()
#endif
			.tint(MiraTheme.ColorToken.primary)
		}
	}
}
