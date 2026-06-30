import SwiftUI

#if os(iOS)
	import UIKit
#endif

struct MiraTextField: View {
	enum Keyboard {
		case text
		case email
	}

	enum ContentType {
		case none
		case username
		case emailAddress
	}

	let label: String
	let placeholder: String
	let errorText: String?
	let keyboard: Keyboard
	let contentType: ContentType

	@Binding var text: String

	init(
		label: String,
		placeholder: String,
		text: Binding<String>,
		errorText: String? = nil,
		keyboard: Keyboard = .text,
		contentType: ContentType = .none
	) {
		self.label = label
		self.placeholder = placeholder
		self._text = text
		self.errorText = errorText
		self.keyboard = keyboard
		self.contentType = contentType
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
				.textContentType(uiTextContentType)
				.autocorrectionDisabled()
			#endif
			.tint(MiraTheme.ColorToken.primary)
			.miraFormInputChrome(isInvalid: isInvalid)

			if let errorText {
				MiraHelperText(errorText, tone: .destructive)
			}
		}
	}

	#if os(iOS)
		private var uiTextContentType: UITextContentType? {
			switch contentType {
			case .none:
				return nil
			case .username:
				return .username
			case .emailAddress:
				return .emailAddress
			}
		}
	#endif
}
