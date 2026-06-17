import Foundation

enum CredentialField: Equatable {
	case username
	case password

	func copyLabel(language: MiraLanguage) -> String {
		switch self {
		case .username:
			return MiraText.copyUsername.localized(language)
		case .password:
			return MiraText.copyPassword.localized(language)
		}
	}
}
