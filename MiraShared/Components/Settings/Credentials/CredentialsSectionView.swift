import SwiftUI

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
			VStack(spacing: 0) {
				Image("utm_logo")
					.resizable()
					.scaledToFit()
					.frame(width: 200, height: 100)
				Text("Technical University of Moldova")
					.font(.title3)
					.fontWeight(.heavy)
					.multilineTextAlignment(.center)
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.bottom, 40)

			credentialRow(
				field: .username,
				title: MiraText.username.localized(language),
				value: credentials.username,
				isSensitive: false,
				isRevealed: true
			)

			Divider()

			credentialRow(
				field: .password,
				title: MiraText.password.localized(language),
				value: credentials.password,
				isSensitive: true,
				isRevealed: isPasswordRevealed
			)
		}
	}

	private var actionRow: some View {
		HStack {
			Spacer()

			if let activeField {
				copyButton(for: activeField)
			} else {
				editButton
			}
		}
		.frame(height: 44)
	}

	private var editButton: some View {
		Button {
			onEdit()
		} label: {
			Image(systemName: "pencil")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.primary)
				.frame(width: 36, height: 36)
		}
		.buttonStyle(.plain)
		.accessibilityLabel("Edit credentials")
	}

	private func copyButton(for field: CredentialField) -> some View {
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
