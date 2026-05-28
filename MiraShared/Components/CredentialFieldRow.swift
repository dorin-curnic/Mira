import SwiftUI

enum CredentialField: Equatable {
	case username, password, portal
}

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
				CredentialFieldRow(
					field: .username,
					title: "Username",
					value: username,
					isSensitive: false,
					isRevealed: true,
					isActive: activeField == .username,
					onTap: { activateField(.username) }
				)
				.anchorPreference(key: RowBoundsKey.self, value: .bounds) {
					[.username: $0]
				}

				Divider()

				CredentialFieldRow(
					field: .password,
					title: "Password",
					value: password,
					isSensitive: true,
					isRevealed: revealedFields.contains(.password),
					isActive: activeField == .password,
					onTap: { activateField(.password, reveal: true) }
				)
				.anchorPreference(key: RowBoundsKey.self, value: .bounds) {
					[.password: $0]
				}

				Divider()

				CredentialFieldRow(
					field: .portal,
					title: "Portal",
					value: portal,
					isSensitive: true,
					isRevealed: revealedFields.contains(.portal),
					isActive: activeField == .portal,
					onTap: { activateField(.portal, reveal: true) }
				)
				.anchorPreference(key: RowBoundsKey.self, value: .bounds) {
					[.portal: $0]
				}
			}
		}
		.overlayPreferenceValue(RowBoundsKey.self) { anchors in
			GeometryReader { geo in
				if let field = activeField, let anchor = anchors[field] {
					floatingCopyButton(for: field)
						.fixedSize()
						.position(
							x: geo.size.width * 0.62,
							y: geo[anchor].minY - 18
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

	@ViewBuilder
	private func floatingCopyButton(for field: CredentialField) -> some View {
		Button {
			performCopy(for: field)
		} label: {
			Text(copyLabel(for: field))
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(.black)
				.padding(.horizontal, 24)
				.padding(.vertical, 12)
				.frame(minHeight: 44)
		}
		.buttonStyle(.miraGlassCopy)
	}

	private func activateField(_ field: CredentialField, reveal: Bool = false) {
		activeField = activeField == field ? nil : field

		if reveal {
			revealedFields.insert(field)
		}
	}

	private func copyLabel(for field: CredentialField) -> String {
		switch field {
		case .username:
			return "Copy Username"
		case .password:
			return "Copy Password"
		case .portal:
			return "Copy Portal"
		}
	}

	private func valueFor(_ field: CredentialField) -> String {
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
		ClipboardService.copy(valueFor(field))
		activeField = nil
	}
}

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
		isSensitive && !isRevealed
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
				Text(title)
					.font(.body)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
					.fixedSize(horizontal: true, vertical: false)

				Spacer(minLength: MiraTheme.Spacing.md)

				Text(displayValue)
					.font(isHiddenSensitiveValue ? .title3 : .body)
					.fontWeight(isHiddenSensitiveValue ? .black : .semibold)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					.multilineTextAlignment(.leading)
					.lineLimit(isActive ? 2 : 1)
					.truncationMode(.tail)
					.frame(maxWidth: .infinity, alignment: .trailing)
					.transaction { transaction in
						transaction.animation = nil
					}
			}
			.padding(.vertical, MiraTheme.Spacing.md)
			.contentShape(Rectangle())
			.transaction { transaction in
				transaction.animation = nil
			}
		}
		.buttonStyle(.plain)
		.transaction { transaction in
			transaction.animation = nil
		}
	}
}

private struct MiraGlassCopyButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		if #available(iOS 26.0, macOS 26.0, *) {
			configuration.label
				.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
				.glassEffect(.regular.interactive(), in: Capsule())
				.overlay {
					Capsule()
						.strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
				}
				.shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
		} else {
			configuration.label
				.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
				.background {
					Capsule()
						.fill(.regularMaterial)
						.overlay {
							Capsule()
								.strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
						}
						.shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
				}
		}
	}
}

private extension ButtonStyle where Self == MiraGlassCopyButtonStyle {
	static var miraGlassCopy: MiraGlassCopyButtonStyle {
		MiraGlassCopyButtonStyle()
	}
}

private extension String {
	func addingSoftBreaks(every interval: Int) -> String {
		guard interval > 0 else { return self }

		var result = ""
		var count = 0

		for character in self {
			result.append(character)
			count += 1

			if count >= interval {
				result.append("\u{200B}")
				count = 0
			}
		}

		return result
	}
}
