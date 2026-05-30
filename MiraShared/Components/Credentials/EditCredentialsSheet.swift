import SwiftUI

struct EditCredentialsSheet: View {
	enum Mode {
		case add
		case edit
	}

	@Environment(\.dismiss) private var dismiss
	@Environment(\.miraLanguage) private var language

	let mode: Mode
	let initialCredentials: WiFiCredentials?
	let onSave: (WiFiCredentials) -> Void
	let onDelete: (() -> Void)?

	@State private var username: String
	@State private var password: String
	@State private var isPasswordVisible = false
	@State private var didTryToSave = false
	@State private var isShowingDeleteConfirmation = false

	init(
		mode: Mode,
		initialCredentials: WiFiCredentials?,
		onSave: @escaping (WiFiCredentials) -> Void,
		onDelete: (() -> Void)? = nil
	) {
		self.mode = mode
		self.initialCredentials = initialCredentials
		self.onSave = onSave
		self.onDelete = onDelete

		_username = State(initialValue: initialCredentials?.username ?? "")
		_password = State(initialValue: initialCredentials?.password ?? "")
	}

	private var title: String {
		switch mode {
		case .add:
			return "Add Credentials"
		case .edit:
			return "Edit Credentials"
		}
	}

	private var usernamePattern: String {
		#"^[A-Za-z0-9._%+-]+\.[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.utm\.md$"#
	}

	private var trimmedUsername: String {
		username.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var isUsernameEmpty: Bool {
		trimmedUsername.isEmpty
	}

	private var isUsernameFormatInvalid: Bool {
		!isUsernameEmpty && trimmedUsername.range(
			of: usernamePattern,
			options: .regularExpression
		) == nil
	}

	private var isPasswordEmpty: Bool {
		password.isEmpty
	}

	private var isUsernameInvalid: Bool {
		didTryToSave && (isUsernameEmpty || isUsernameFormatInvalid)
	}

	private var isPasswordInvalid: Bool {
		didTryToSave && isPasswordEmpty
	}

	private var canSave: Bool {
		!isUsernameEmpty && !isUsernameFormatInvalid && !isPasswordEmpty
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
					header
					formCard
					securityNote
				}
				.padding(MiraTheme.Spacing.xl)
				.frame(maxWidth: 560)
				.frame(maxWidth: .infinity)
			}
			.background(MiraTheme.ColorToken.background)
			.navigationTitle(title)
#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "xmark")
							.fontWeight(.semibold)
					}
					.tint(MiraTheme.ColorToken.foreground)
				}

				ToolbarItem(placement: .confirmationAction) {
					Button {
						save()
					} label: {
						Image(systemName: "checkmark")
							.fontWeight(.semibold)
					}
					.disabled(!canSave)
					.tint(MiraTheme.ColorToken.primary)
				}
			}
			.confirmationDialog(
				"Delete credentials?",
				isPresented: $isShowingDeleteConfirmation,
				titleVisibility: .visible
			) {
				Button("Delete Credentials", role: .destructive) {
					onDelete?()
					dismiss()
				}

				Button("Cancel", role: .cancel) {}
			} message: {
				Text("This will remove your saved username and password from this device.")
			}
		}
	}

	private var header: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text(title)
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text("Add your university Wi-Fi username and password.")
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private var formCard: some View {
		MiraCard {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.lg) {
				usernameField

				Divider()

				passwordField

				if mode == .edit {
					Divider()

					deleteButton
				}
			}
		}
	}

	private var usernameField: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			Text(.username, language: language)
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			TextField("name.surname@xyz.utm.md", text: $username)
#if os(iOS)
				.textInputAutocapitalization(.never)
				.keyboardType(.emailAddress)
				.autocorrectionDisabled()
#endif
				.tint(MiraTheme.ColorToken.primary)
				.padding(.horizontal, MiraTheme.Spacing.md)
				.padding(.vertical, MiraTheme.Spacing.md)
				.background(MiraTheme.ColorToken.secondary)
				.clipShape(
					RoundedRectangle(
						cornerRadius: MiraTheme.Radius.md,
						style: .continuous
					)
				)
				.overlay {
					RoundedRectangle(
						cornerRadius: MiraTheme.Radius.md,
						style: .continuous
					)
					.stroke(
						isUsernameInvalid
						? MiraTheme.ColorToken.destructive
						: MiraTheme.ColorToken.border,
						lineWidth: 1
					)
				}

			if isUsernameInvalid {
				Text(usernameErrorText)
					.font(.caption)
					.foregroundStyle(MiraTheme.ColorToken.destructive)
			}
		}
	}

	private var usernameErrorText: String {
		if isUsernameEmpty {
			return "Username is required."
		}

		return "Use format: name.surname@xyz.utm.md"
	}

	private var passwordField: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			Text(.password, language: language)
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			HStack(spacing: MiraTheme.Spacing.sm) {
				Group {
					if isPasswordVisible {
						TextField("Password", text: $password)
					} else {
						SecureField("Password", text: $password)
					}
				}
#if os(iOS)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
#endif
				.tint(MiraTheme.ColorToken.primary)

				Button {
					isPasswordVisible.toggle()
				} label: {
					Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
				}
				.buttonStyle(.plain)
			}
			.padding(.horizontal, MiraTheme.Spacing.md)
			.padding(.vertical, MiraTheme.Spacing.md)
			.background(MiraTheme.ColorToken.secondary)
			.clipShape(
				RoundedRectangle(
					cornerRadius: MiraTheme.Radius.md,
					style: .continuous
				)
			)
			.overlay {
				RoundedRectangle(
					cornerRadius: MiraTheme.Radius.md,
					style: .continuous
				)
				.stroke(
					isPasswordInvalid
					? MiraTheme.ColorToken.destructive
					: MiraTheme.ColorToken.border,
					lineWidth: 1
				)
			}

			if isPasswordInvalid {
				Text("Password is required.")
					.font(.caption)
					.foregroundStyle(MiraTheme.ColorToken.destructive)
			}
		}
	}

	private var deleteButton: some View {
		Button(role: .destructive) {
			isShowingDeleteConfirmation = true
		} label: {
			HStack {
				Spacer()

				Text("Delete Credentials")
					.fontWeight(.semibold)

				Spacer()
			}
			.frame(height: 24)
		}
		.buttonStyle(.bordered)
		.tint(MiraTheme.ColorToken.destructive)
	}

	private var securityNote: some View {
		HStack(alignment: .top, spacing: MiraTheme.Spacing.md) {
			Image(systemName: "lock.shield")
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

			Text("Credentials will be stored securely on this device.")
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private func save() {
		didTryToSave = true

		guard canSave else {
			return
		}

		let credentials = WiFiCredentials(
			username: trimmedUsername,
			password: password
		)

		onSave(credentials)
		dismiss()
	}
}
