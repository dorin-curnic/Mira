import SwiftUI

private struct SavedCredentialRowBoundsKey: PreferenceKey {
	static var defaultValue: [CredentialField: Anchor<CGRect>] = [:]

	static func reduce(
		value: inout [CredentialField: Anchor<CGRect>],
		nextValue: () -> [CredentialField: Anchor<CGRect>]
	) {
		value.merge(nextValue(), uniquingKeysWith: { $1 })
	}
}

struct SavedCredentialsView: View {
	@Environment(\.miraLanguage) private var language

	let credentials: WiFiCredentials
	let isPasswordRevealed: Bool
	let onPasswordTap: () -> Void
	let onCopy: (CredentialField) -> Void

	@State private var activeField: CredentialField?

	private var passwordDisplayValue: String {
		isPasswordRevealed
		? credentials.password
		: String(repeating: "•", count: max(credentials.password.count, 12))
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			row(
				field: .username,
				title: MiraText.username.localized(language),
				value: credentials.username,
				isSensitiveHidden: false,
				action: {
					toggleCopyButton(for: .username)
				}
			)
			.anchorPreference(key: SavedCredentialRowBoundsKey.self, value: .bounds) {
				[.username: $0]
			}

			Divider()

			row(
				field: .password,
				title: MiraText.password.localized(language),
				value: passwordDisplayValue,
				isSensitiveHidden: !isPasswordRevealed,
				action: {
					if isPasswordRevealed {
						toggleCopyButton(for: .password)
					} else {
						onPasswordTap()
					}
				}
			)
			.anchorPreference(key: SavedCredentialRowBoundsKey.self, value: .bounds) {
				[.password: $0]
			}
		}
		.overlayPreferenceValue(SavedCredentialRowBoundsKey.self) { anchors in
			GeometryReader { geometry in
				if let activeField, let anchor = anchors[activeField] {
					floatingCopyButton(for: activeField)
						.fixedSize()
						.position(
							x: geometry.size.width * 0.62,
							y: geometry[anchor].minY - 18
						)
						.transition(
							.asymmetric(
								insertion: .scale(scale: 0.92)
									.combined(with: .opacity),
								removal: .identity
							)
						)
						.zIndex(10)
				}
			}
			.animation(
				.spring(response: 0.22, dampingFraction: 0.68),
				value: activeField
			)
		}
	}

	private func row(
		field: CredentialField,
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

	@ViewBuilder
	private func floatingCopyButton(for field: CredentialField) -> some View {
		Button {
			onCopy(field)
			activeField = nil
		} label: {
			Text(field.copyLabel(language: language))
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.padding(.horizontal, 24)
				.padding(.vertical, 12)
				.frame(minHeight: 44)
		}
		.buttonStyle(.miraGlassCopy)
	}

	private func toggleCopyButton(for field: CredentialField) {
		activeField = activeField == field ? nil : field
	}
}
