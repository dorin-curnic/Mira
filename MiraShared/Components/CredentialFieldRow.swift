import SwiftUI

struct Credential {
	var title: String
	var username: String
	var password: String
	var portal: String
	var iconName: String
	var iconColor: Color
}

enum CredentialField: Equatable {
	case username, password, portal
}

struct CredentialDetailView: View {
	let credential: Credential

	@State private var activeField: CredentialField? = nil
	@State private var revealedFields: Set<CredentialField> = []
	@State private var copiedField: CredentialField? = nil
	@State private var showCopiedToast: Bool = false

	var body: some View {
		ZStack {
			Color(.systemGroupedBackground)
				.ignoresSafeArea()

			ScrollView {
				VStack(spacing: 0) {
					headerSection

					credentialsCard
						.padding(.horizontal, 16)
						.padding(.top, 28)

					Spacer(minLength: 80)
				}
			}
			.overlay(alignment: .bottom) {
				if let field = activeField {
					floatingCopyButton(for: field)
						.transition(
							.asymmetric(
								insertion: .move(edge: .bottom).combined(with: .opacity),
								removal: .move(edge: .bottom).combined(with: .opacity)
							)
						)
						.padding(.bottom, 24)
				}
			}

			if showCopiedToast {
				copiedToast
			}
		}
		.navigationTitle(credential.title)
		.navigationBarTitleDisplayMode(.inline)
		.onTapGesture {
			withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
				activeField = nil
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button("Edit") {}
					.fontWeight(.regular)
			}
		}
	}

	private var headerSection: some View {
		VStack(spacing: 12) {
			ZStack {
				RoundedRectangle(cornerRadius: 22, style: .continuous)
					.fill(credential.iconColor.gradient)
					.frame(width: 80, height: 80)
					.shadow(color: credential.iconColor.opacity(0.4), radius: 12, y: 6)

				Image(systemName: credential.iconName)
					.font(.system(size: 34, weight: .medium))
					.foregroundStyle(.white)
			}
			.padding(.top, 24)

			Text(credential.title)
				.font(.title2)
				.fontWeight(.semibold)
				.foregroundStyle(.primary)
		}
	}

	private var credentialsCard: some View {
		VStack(spacing: 0) {
			CredentialFieldRow(
				field: .username,
				title: "Username",
				value: credential.username,
				isSensitive: false,
				isRevealed: true,
				isActive: activeField == .username,
				onTap: {
					withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
						activeField = activeField == .username ? nil : .username
					}
				}
			)

			Divider()
				.padding(.leading, 16)

			CredentialFieldRow(
				field: .password,
				title: "Password",
				value: credential.password,
				isSensitive: true,
				isRevealed: revealedFields.contains(.password),
				isActive: activeField == .password,
				onTap: {
					withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
						activeField = activeField == .password ? nil : .password
						revealedFields.insert(.password)
					}
				}
			)

			Divider()
				.padding(.leading, 16)

			CredentialFieldRow(
				field: .portal,
				title: "Portal",
				value: credential.portal,
				isSensitive: true,
				isRevealed: revealedFields.contains(.portal),
				isActive: activeField == .portal,
				onTap: {
					withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
						activeField = activeField == .portal ? nil : .portal
						revealedFields.insert(.portal)
					}
				}
			)
		}
		.background(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.fill(Color(.secondarySystemGroupedBackground))
		)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}

	@ViewBuilder
	private func floatingCopyButton(for field: CredentialField) -> some View {
		Button {
			performCopy(for: field)
		} label: {
			HStack(spacing: 10) {
				Image(systemName: copiedField == field ? "checkmark" : "doc.on.doc")
					.font(.system(size: 15, weight: .semibold))
					.contentTransition(.symbolEffect(.replace))

				Text(copyLabel(for: field))
					.font(.system(size: 15, weight: .semibold))
			}
			.foregroundStyle(.white)
			.padding(.horizontal, 22)
			.padding(.vertical, 14)
			.background {
				Capsule()
					.fill(.ultraThinMaterial)
					.overlay {
						Capsule()
							.fill(
								LinearGradient(
									colors: [
										Color(.systemBlue).opacity(0.85),
										Color(.systemBlue).opacity(0.6)
									],
									startPoint: .topLeading,
									endPoint: .bottomTrailing
								)
							)
					}
					.overlay {
						Capsule()
							.strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
					}
					.shadow(color: Color(.systemBlue).opacity(0.45), radius: 16, y: 8)
					.shadow(color: .black.opacity(0.2), radius: 4, y: 2)
			}
		}
		.buttonStyle(FloatingButtonStyle())
	}

	private var copiedToast: some View {
		VStack {
			Spacer()
			HStack(spacing: 8) {
				Image(systemName: "checkmark.circle.fill")
					.foregroundStyle(.green)
				Text("Copied to clipboard")
					.font(.subheadline)
					.fontWeight(.medium)
			}
			.padding(.horizontal, 18)
			.padding(.vertical, 12)
			.background(
				Capsule()
					.fill(.regularMaterial)
					.shadow(color: .black.opacity(0.12), radius: 12, y: 4)
			)
			.padding(.bottom, 100)
		}
		.transition(.move(edge: .bottom).combined(with: .opacity))
	}

	private func copyLabel(for field: CredentialField) -> String {
		switch field {
		case .username: return "Copy Username"
		case .password: return "Copy Password"
		case .portal:   return "Copy Portal"
		}
	}

	private func performCopy(for field: CredentialField) {
		let value: String
		switch field {
		case .username: value = credential.username
		case .password: value = credential.password
		case .portal:   value = credential.portal
		}

		UIPasteboard.general.string = value

		withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
			copiedField = field
		}

		withAnimation(.easeInOut(duration: 0.3)) {
			showCopiedToast = true
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			withAnimation(.easeInOut(duration: 0.3)) {
				showCopiedToast = false
			}
			withAnimation(.spring(response: 0.3)) {
				copiedField = nil
				activeField = nil
			}
		}
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

	private var displayValue: String {
		if isSensitive && !isRevealed {
			return String(repeating: "•", count: max(value.count, 10))
		}
		return value
	}

	var body: some View {
		Button(action: onTap) {
			HStack(spacing: 12) {
				VStack(alignment: .leading, spacing: 3) {
					Text(title)
						.font(.caption)
						.fontWeight(.medium)
						.foregroundStyle(isActive ? Color(.systemBlue) : Color(.secondaryLabel))

					Text(displayValue)
						.font(.body)
						.foregroundStyle(Color(.label))
						.lineLimit(1)
						.animation(.easeInOut(duration: 0.2), value: isRevealed)
				}

				Spacer()

				if isSensitive {
					Image(systemName: isRevealed ? "eye.slash" : "eye")
						.font(.system(size: 14, weight: .medium))
						.foregroundStyle(Color(.tertiaryLabel))
						.frame(width: 24, height: 24)
				}

				Image(systemName: "chevron.right")
					.font(.system(size: 12, weight: .semibold))
					.foregroundStyle(Color(.tertiaryLabel))
					.rotationEffect(isActive ? .degrees(90) : .degrees(0))
					.animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 14)
			.contentShape(Rectangle())
			.background(
				isActive
				? Color(.systemBlue).opacity(0.06)
				: Color.clear
			)
			.animation(.easeInOut(duration: 0.15), value: isActive)
		}
		.buttonStyle(.plain)
	}
}

struct FloatingButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.94 : 1.0)
			.opacity(configuration.isPressed ? 0.88 : 1.0)
			.animation(.spring(response: 0.2, dampingFraction: 0.65), value: configuration.isPressed)
	}
}

#Preview {
	NavigationStack {
		CredentialDetailView(
			credential: Credential(
				title: "GitHub",
				username: "john.doe@example.com",
				password: "S3cur3P@ssw0rd!",
				portal: "https://github.com/login",
				iconName: "chevron.left.forwardslash.chevron.right",
				iconColor: Color(.systemPurple)
			)
		)
	}
}
