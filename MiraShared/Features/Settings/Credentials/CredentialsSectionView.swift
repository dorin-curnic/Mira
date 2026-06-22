import SwiftUI

private struct CredentialRowBoundsKey: PreferenceKey {
	static var defaultValue: [CredentialField: Anchor<CGRect>] = [:]

	static func reduce(
		value: inout [CredentialField: Anchor<CGRect>],
		nextValue: () -> [CredentialField: Anchor<CGRect>]
	) {
		value.merge(nextValue(), uniquingKeysWith: { $1 })
	}
}

struct CredentialsSectionView: View {
	@Environment(\.miraLanguage) private var language

	let credentials: WiFiCredentials
	let isPasswordRevealed: Bool
	let onRevealPassword: () -> Void
	let onCopy: (CredentialField) -> Void
	let onEdit: () -> Void

	@State private var activeField: CredentialField?

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			header

			credentialRow(
				field: .username,
				title: MiraText.username.localized(language),
				value: credentials.username,
				isSensitive: false,
				isRevealed: true
			)
			.anchorPreference(key: CredentialRowBoundsKey.self, value: .bounds) {
				[.username: $0]
			}

			Divider()

			credentialRow(
				field: .password,
				title: MiraText.password.localized(language),
				value: credentials.password,
				isSensitive: true,
				isRevealed: isPasswordRevealed
			)
			.anchorPreference(key: CredentialRowBoundsKey.self, value: .bounds) {
				[.password: $0]
			}
		}
		.overlayPreferenceValue(CredentialRowBoundsKey.self) { anchors in
			GeometryReader { geometry in
				if let activeField, let anchor = anchors[activeField] {
					floatingCopyButton(for: activeField)
						.fixedSize()
						.position(
							x: geometry.size.width * 0.68,
							y: geometry[anchor].minY - 18
						)
						.transition(
							.asymmetric(
								insertion: .scale(scale: 0.92).combined(with: .opacity),
								removal: .opacity
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

	private var header: some View {
		VStack(spacing: MiraTheme.Spacing.sm) {
			Image("utm_logo")
				.resizable()
				.scaledToFit()
				.frame(width: 140, height: 100)

			Text(MiraText.universityName.localized(language))
				.font(MiraTheme.Typography.sectionTitle)
				.fontWeight(MiraTheme.Typography.sectionTitleWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.multilineTextAlignment(.center)

			editButton
				.padding(.top, MiraTheme.Spacing.xs)
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.padding(.bottom, MiraTheme.Spacing.xl)
	}

	private var editButton: some View {
		Button {
			onEdit()
		} label: {
			Label(MiraText.credentialsEditButton.localized(language), systemImage: "pencil")
				.font(MiraTheme.Typography.button)
				.fontWeight(MiraTheme.Typography.buttonWeight)
				.foregroundStyle(MiraTheme.ColorToken.primary)
				.labelStyle(.titleAndIcon)
				.padding(.horizontal, MiraTheme.Spacing.md)
				.padding(.vertical, MiraTheme.Spacing.sm)
				.background {
					Capsule()
						.fill(MiraTheme.ColorToken.primary.opacity(0.10))
				}
		}
		.buttonStyle(.plain)
		.accessibilityLabel(MiraText.credentialsEditButton.localized(language))
	}

	private func credentialRow(
		field: CredentialField,
		title: String,
		value: String,
		isSensitive: Bool,
		isRevealed: Bool
	) -> some View {
		CredentialFieldRow(
			field: field,
			title: title,
			value: value,
			isSensitive: isSensitive,
			isRevealed: isRevealed,
			isActive: activeField == field,
			onTap: {
				handleTap(on: field)
			}
		)
	}

	private func floatingCopyButton(for field: CredentialField) -> some View {
		Button {
			onCopy(field)
			activeField = nil
		} label: {
			Text(field.copyLabel(language: language))
				.font(MiraTheme.Typography.button)
				.fontWeight(MiraTheme.Typography.buttonWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.padding(.horizontal, 24)
				.padding(.vertical, 12)
				.frame(minHeight: 44)
		}
		.buttonStyle(.miraGlassCopy)
	}

	private func handleTap(on field: CredentialField) {
		switch field {
		case .username:
			toggleCopyButton(for: .username)

		case .password:
			if isPasswordRevealed {
				toggleCopyButton(for: .password)
			} else {
				onRevealPassword()
			}
		}
	}

	private func toggleCopyButton(for field: CredentialField) {
		activeField = activeField == field ? nil : field
	}
}
