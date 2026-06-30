import SwiftUI

struct EditCredentialsSheet: View {
	enum Mode {
		case add
		case edit
	}

	@Environment(\.dismiss) private var dismiss
	@Environment(\.miraLanguage) private var language

	@State private var username: String
	@State private var password: String
	@State private var didTryToSave = false
	@State private var isShowingDeleteConfirmation = false

	let mode: Mode
	let initialCredentials: WiFiCredentials?
	let onSave: (WiFiCredentials) -> Void
	let onDelete: (() -> Void)?

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
			return MiraText.credentialsAddTitle.localized(language)
		case .edit:
			return MiraText.credentialsEditTitle.localized(language)
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
		!isUsernameEmpty
			&& trimmedUsername.range(
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
			MiraSheetContainer {
				header
				formCard
			}
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
							.fontWeight(MiraTheme.Typography.buttonWeight)
					}
					.tint(MiraTheme.ColorToken.foreground)
				}

				ToolbarItem(placement: .confirmationAction) {
					Button {
						save()
					} label: {
						Image(systemName: "checkmark")
							.fontWeight(MiraTheme.Typography.buttonWeight)
					}
					.tint(MiraTheme.ColorToken.primary)
				}
			}
			.alert(
				MiraText.credentialsDeleteQuestion.localized(language),
				isPresented: $isShowingDeleteConfirmation
			) {
				Button(MiraText.commonCancel.localized(language), role: .cancel) {}

				Button(MiraText.credentialsDeleteButton.localized(language), role: .destructive) {
					onDelete?()
					dismiss()
				}
			} message: {
				Text(MiraText.credentialsDeleteMessage.localized(language))
			}
		}
	}

	private var header: some View {
		MiraPageHeader(
			title,
			subtitle: MiraText.credentialsSheetSubtitle.localized(language)
		)
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
		MiraTextField(
			label: MiraText.username.localized(language),
			placeholder: MiraText.credentialsUsernamePlaceholder.localized(language),
			text: $username,
			errorText: isUsernameInvalid ? usernameErrorText : nil,
			keyboard: .email,
			contentType: .username
		)
	}

	private var usernameErrorText: String {
		if isUsernameEmpty {
			return MiraText.credentialsUsernameRequiredError.localized(language)
		}

		return MiraText.credentialsUsernameFormatError.localized(language)
	}

	private var passwordField: some View {
		MiraPasswordField(
			label: MiraText.password.localized(language),
			placeholder: MiraText.credentialsPasswordPlaceholder.localized(language),
			text: $password,
			errorText: isPasswordInvalid
				? MiraText.credentialsPasswordRequiredError.localized(language) : nil
		)
	}

	private var deleteButton: some View {
		Button(role: .destructive) {
			isShowingDeleteConfirmation = true
		} label: {
			HStack {
				Spacer()

				Text(MiraText.credentialsDeleteButton.localized(language))
					.font(MiraTheme.Typography.button)
					.fontWeight(MiraTheme.Typography.buttonWeight)

				Spacer()
			}
			.frame(height: 24)
		}
		.buttonStyle(.bordered)
		.tint(MiraTheme.ColorToken.destructive)
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
