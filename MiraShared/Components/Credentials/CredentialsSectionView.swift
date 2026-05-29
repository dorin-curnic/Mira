import SwiftUI

private struct RowBoundsKey: PreferenceKey {
	static var defaultValue: [CredentialField: Anchor<CGRect>] = [:]

	static func reduce(
		value: inout [CredentialField: Anchor<CGRect>],
		nextValue: () -> [CredentialField: Anchor<CGRect>]
	) {
		value.merge(nextValue(), uniquingKeysWith: { $1 })
	}
}

struct CredentialsSectionView: View {
	let username: String
	let password: String
	let portal: String

	@Binding var activeField: CredentialField?
	@State private var revealedFields: Set<CredentialField> = []

	var body: some View {
		MiraCard {
			VStack(alignment: .leading, spacing: 0) {
				credentialRow(
					field: .username,
					title: "Username",
					value: username,
					isSensitive: false
				)

				Divider()

				credentialRow(
					field: .password,
					title: "Password",
					value: password,
					isSensitive: true
				)

				Divider()

				credentialRow(
					field: .portal,
					title: "Portal",
					value: portal,
					isSensitive: true
				)
			}
		}
		.overlayPreferenceValue(RowBoundsKey.self) { anchors in
			GeometryReader { geometry in
				if let field = activeField, let anchor = anchors[field] {
					floatingCopyButton(for: field)
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

	private func credentialRow(
		field: CredentialField,
		title: String,
		value: String,
		isSensitive: Bool
	) -> some View {
		CredentialFieldRow(
			field: field,
			title: title,
			value: value,
			isSensitive: isSensitive,
			isRevealed: isRevealed(field),
			isActive: activeField == field,
			onTap: {
				activateField(field, reveal: isSensitive)
			}
		)
		.anchorPreference(key: RowBoundsKey.self, value: .bounds) {
			[field: $0]
		}
	}

	@ViewBuilder
	private func floatingCopyButton(for field: CredentialField) -> some View {
		Button {
			performCopy(for: field)
		} label: {
			Text(field.copyLabel)
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.padding(.horizontal, 24)
				.padding(.vertical, 12)
				.frame(minHeight: 44)
		}
		.buttonStyle(.miraGlassCopy)
	}

	private func isRevealed(_ field: CredentialField) -> Bool {
		switch field {
		case .username:
			return true
		case .password, .portal:
			return revealedFields.contains(field)
		}
	}

	private func activateField(_ field: CredentialField, reveal: Bool = false) {
		activeField = activeField == field ? nil : field

		if reveal {
			revealedFields.insert(field)
		}
	}

	private func value(for field: CredentialField) -> String {
		switch field {
		case .username:
			return username
		case .password:
			return password
		case .portal:
			return portal
		}
	}

	private func performCopy(for field: CredentialField) {
		ClipboardService.copy(value(for: field))
		activeField = nil
	}
}
