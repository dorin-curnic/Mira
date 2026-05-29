import SwiftUI

struct SavedCredentialsView: View {
	@Environment(\.miraLanguage) private var language

	let credentials: WiFiCredentials
	let isPasswordRevealed: Bool
	let onPasswordTap: () -> Void

	private var passwordDisplayValue: String {
		isPasswordRevealed
		? credentials.password
		: String(repeating: "•", count: max(credentials.password.count, 12))
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			row(
				title: MiraText.username.localized(language),
				value: credentials.username,
				isSensitiveHidden: false,
				action: {}
			)

			Divider()

			row(
				title: MiraText.password.localized(language),
				value: passwordDisplayValue,
				isSensitiveHidden: !isPasswordRevealed,
				action: onPasswordTap
			)
		}
	}

	private func row(
		title: String,
		value: String,
		isSensitiveHidden: Bool,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			HStack(alignment: .top, spacing: 0) {
				Text(title)
					.font(.body)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
					.fixedSize(horizontal: true, vertical: false)

				Spacer(minLength: MiraTheme.Spacing.md)

				Text(value)
					.font(isSensitiveHidden ? .title3 : .body)
					.fontWeight(isSensitiveHidden ? .black : .semibold)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					.multilineTextAlignment(.leading)
					.lineLimit(1)
					.truncationMode(.tail)
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
			.padding(.vertical, MiraTheme.Spacing.md)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}
}
